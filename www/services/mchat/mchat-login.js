import { DocumentUtil } from '../../utils/document.js';
import { UrlUtil } from '../../utils/url.js';

function MchatLoginService({ baseUrl, fetchTool }) {
  const urlUtil = UrlUtil();
  const documentUtil = DocumentUtil();
  const forumName = urlUtil.convertUrlToName(baseUrl);

  let loginPageData;
  let otpData;

  async function init() {
    loginPageData = await getLoginPageData();
  }

  async function getLoginPageData() {
    const targetURL = `${baseUrl}/ucp.php?mode=login`;
    const options = { method: 'GET', redirect: 'manual' };
    const loginPage = await fetchTool.fetchCrossDomain(targetURL, options);
    const loginPageText = await loginPage.text();
    if (!loginPageText.includes('dmzx/mchat'))
      throw 'MChat not found on this page.';
    const doc = new DOMParser().parseFromString(loginPageText, 'text/html');
    return {
      creationTime: documentUtil.findInputData(doc, 'creation_time', 'value'),
      formToken: documentUtil.findInputData(doc, 'form_token', 'value'),
      sid: documentUtil.findInputData(doc, 'sid', 'value'),
      login: documentUtil.findInputData(doc, 'login', 'value'),
      cookie: documentUtil.extractCookie(loginPage.headers)
    };
  }

  async function loginWithCredentials(username, password) {
    const targetURL = `${baseUrl}/ucp.php?mode=login`;
    const headers = { 'content-type': 'application/x-www-form-urlencoded' };
    headers.cookie = loginPageData.cookie;
    const body = {
      username,
      password,
      creation_time: loginPageData.creationTime,
      form_token: loginPageData.formToken,
      sid: loginPageData.sid,
      login: loginPageData.login,
      redirect: 'index.php',
      autologin: 'on',
      redirect: './ucp.php?mode=login'
    };
    const options = { headers, body, redirect: 'manual', method: 'POST' };
    const page = await fetchTool.fetchCrossDomain(targetURL, options);
    await checkErrors(page);
    if (documentUtil.hasSessionCookie(page)) {
      const cookie = documentUtil.extractCookie(page.headers);
      return {
        cookie,
        userId: documentUtil.extractUserId(cookie),
        secondFactorRequired: false,
        forumName
      };
    }
    const otpPageText = await page.text();
    const doc = new DOMParser().parseFromString(otpPageText, 'text/html');
    otpData = {
      creationTime: documentUtil.findInputData(doc, 'creation_time', 'value'),
      formToken: documentUtil.findInputData(doc, 'form_token', 'value'),
      creationTime: documentUtil.findInputData(doc, 'creation_time', 'value'),
      formToken: documentUtil.findInputData(doc, 'form_token', 'value'),
      random: documentUtil.findInputData(doc, 'random', 'value'),
      sid: documentUtil.findInputData(doc, 'sid', 'value'),
      submit: documentUtil.findInputData(
        doc,
        '#auth_otp > #submit_auth',
        'action'
      ),
      cookie: loginPageData.cookie
    };
    return {
      cookie: loginPageData.cookie,
      secondFactorRequired: true,
      forumName
    };
  }

  async function loginWithOtp(otpCode) {
    const targetURL = `${baseUrl}${otpData.submit}`;
    const targetHeaders = {
      'content-type': 'application/x-www-form-urlencoded'
    };
    targetHeaders.cookie = otpData.cookie;
    const options = {
      headers: targetHeaders,
      method: 'POST',
      redirect: 'manual',
      body: {
        creation_time: otpData.creationTime,
        form_token: otpData.formToken,
        sid: otpData.sid,
        random: otpData.random,
        authenticate: otpCode,
        redirect: 'index.php'
      }
    };
    const page = await fetchTool.fetchCrossDomain(targetURL, options);
    const { status, headers } = page;
    await checkErrors(page);
    if (status === 302) {
      const cookie = documentUtil.extractCookie(headers);
      return {
        cookie,
        userId: documentUtil.extractUserId(cookie),
        forumName
      };
    }
    return null;
  }

  async function checkErrors(page) {
    const text = await page.text();
    const doc = new DOMParser().parseFromString(text, 'text/html');
    const [errorElement] = doc.getElementsByClassName('error');
    if (errorElement) throw errorElement.innerText.replace(/ +/gi, ' ');
  }

  async function logout(cookieStore) {
    const cookie = await cookieStore.get();
    const sid = cookie.split('_sid=')[1].split(';')[0];
    const targetURL = `${baseUrl}/ucp.php?mode=logout&sid=${sid}`;
    const headers = { cookie };
    const options = { headers, redirect: 'manual', method: 'GET' };
    await fetchTool.fetchCrossDomain(targetURL, options);
  }

  return { init, loginWithCredentials, loginWithOtp, logout, loginPageData };
}

export { MchatLoginService };
