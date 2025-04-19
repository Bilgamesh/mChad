import { HapticsUtil } from '../../../utils/haptics.js';
import { ThemeUtil } from '../../../utils/theme.js';
import { sleep } from '../../../utils/sleep.js';
import { Languages } from '../../../languages/languages.js';

function LoginUi({ el, forumIndex }) {
  const languages = Languages();
  const themeUtil = ThemeUtil();
  const hapticsUtil = HapticsUtil();

  let addressFocusCount = 0;

  function registerHaptics() {
    document
      .getElementById('back-btn-1')
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById('back-btn-2')
      .addEventListener('click', hapticsUtil.tapDefault);
    document.getElementById('submit-btn').addEventListener('click', (e) => {
      if (cordova.platformId === 'browser') return;
      if (e.screenX !== 0 || e.touches[0].screenX !== 0)
        hapticsUtil.tapDefault();
    });
    document.getElementById('submit-otp-btn').addEventListener('click', (e) => {
      if (cordova.platformId === 'browser') return;
      if (e.screenX !== 0 || e.touches[0].screenX !== 0)
        hapticsUtil.tapDefault();
    });
    document
      .getElementById('pw-visibility-icon')
      .addEventListener('click', hapticsUtil.tapDefault);
  }

  function preventDefaultFormBehavior() {
    document
      .getElementById('login-form')
      .addEventListener('submit', (e) => e.preventDefault());
    document
      .getElementById('otp-form')
      .addEventListener('submi', (e) => e.preventDefault());
  }

  function registerBackButtons() {
    document
      .getElementById('back-btn-1')
      .addEventListener('click', () => history.back());
    document
      .getElementById('back-btn-2')
      .addEventListener('click', () => history.back());
  }

  function init() {
    preventDefaultFormBehavior();
    setLoginColors();
    registerHaptics();
    registerBackButtons();
    addAddressFocusListener(() => {
      addressFocusCount++;
    });
    document
      .getElementById('username')
      .addEventListener('focus', () => clear('username'));
    document
      .getElementById('password')
      .addEventListener('focus', () => clear('password'));
    document
      .getElementById('pw-visibility-icon')
      .addEventListener('click', togglePasswordVisibility);
  }

  async function displayPage() {
    /* Emptying the page just before re-rendering
      and giving browser an overhead via dummy timeout
      makes BeerCSS transition animations much smoother */
    while (el.firstChild) el.removeChild(el.firstChild);
    await sleep(0);

    el.innerHTML = /* HTML */ `<div class="login-main-page">
      <article
        class="medium middle-align center-align login-article page top active"
      >
        <center id="loading-circle" hide="false">
          <progress class="circle large"></progress>
        </center>
        <center>
          <div id="login-form">
            <form id="login-form-inner" onsubmit="return false">
              <i class="extra">forum</i>
              <h5>${await languages.getTranslation('LOGIN_TITLE')}</h5>
              <br />
              <br />
              <div class="field label border round">
                <input id="address" type="text" />
                <label
                  >${await languages.getTranslation('FORUM_ADDRESS')}</label
                >
                <span id="address-error" class="error" hide="true"></span>
                <progress
                  id="address-progress"
                  class="circle small"
                  hide="true"
                ></progress>
                <i id="address-error-icon" hide="true">error</i>
                <i id="address-success-icon" hide="true">check_circle</i>
              </div>

              <div class="field label border round">
                <input id="username" type="text" />
                <label>${await languages.getTranslation('USERNAME')}</label>
                <span id="username-error" class="error" hide="true"></span>
              </div>

              <div class="field label border round">
                <input id="password" type="password" />
                <label>${await languages.getTranslation('PASSWORD')}</label>
                <i id="pw-visibility-icon" class="visibility-icon"
                  >visibility</i
                >
                <span id="password-error" class="error" hide="true"> </span>
              </div>
              <br />
              <center>
                <nav class="center-align">
                  <button
                    id="back-btn-1"
                    class="border open ripple"
                    onclick="return false"
                    type="reset"
                    ${forumIndex == 0 ? 'disabled' : ''}
                  >
                    <i>arrow_back</i>
                    <span>${await languages.getTranslation('BACK')}</span>
                  </button>
                  <button
                    id="submit-btn"
                    class="border open ripple"
                    type="submit"
                    onclick="return false"
                  >
                    <i>login</i>
                    <span>${await languages.getTranslation('NEXT')}</span>
                  </button>
                </nav>
              </center>
            </form>
          </div>
          <div id="otp-form" hide="true">
            <form id="otp-form-inner" onsubmit="return false">
              <i class="extra">forum</i>
              <h5>${await languages.getTranslation('LOGIN_TITLE')}</h5>
              <div class="field label border round">
                <input id="otp" type="number" />
                <label>${await languages.getTranslation('OTP')}</label>
                <span id="otp-error" class="error" hide="true"></span>
              </div>
              <br />
              <center>
                <nav class="center-align">
                  <button
                    id="back-btn-2"
                    class="border open ripple"
                    onclick="return false"
                    type="reset"
                  >
                    <i>arrow_back</i>
                    <span>${await languages.getTranslation('BACK')}</span>
                  </button>
                  <button
                    id="submit-otp-btn"
                    class="border open ripple"
                    class="login-button"
                    type="text"
                    onclick="return false"
                  >
                    <i>login</i>
                    <span>${await languages.getTranslation('NEXT')}</span>
                  </button>
                </nav>
              </center>
            </form>
          </div>
        </center>
      </article>
    </div>`;
  }

  function setLoginColors() {
    themeUtil.updateBarsByElementColor(
      document.getElementsByClassName('login-article')[0],
      '--surface-container-low'
    );
  }

  function restoreNavbarColors() {
    themeUtil.updateBarsByElementColor(
      document.getElementById('navbar-top'),
      '--surface-container'
    );
  }

  function showLoadingScreen() {
    document.getElementById('loading-circle').setAttribute('hide', 'false');
  }

  function hideLoadingScreen() {
    document.getElementById('loading-circle').setAttribute('hide', 'true');
  }

  function showLoginForm() {
    document.getElementById('login-form').setAttribute('hide', 'false');
    document.getElementById('login-form').hidden = false;
  }

  function hideLoginForm() {
    document.getElementById('login-form').hidden = true;
    document.getElementById('login-form').setAttribute('hide', 'true');
  }

  function showOtpForm() {
    document.getElementById('otp-form').setAttribute('hide', 'false');
    document.getElementById('otp-form').hidden = false;
  }

  function hideOtpForm() {
    document.getElementById('otp-form').hidden = true;
    document.getElementById('otp-form').setAttribute('hide', 'true');
  }

  function resetForm(full = false) {
    if (full) {
      document.getElementById('address').value = '';
      document.getElementById('username').value = '';
    }
    document.getElementById('password').value = '';
    document.getElementById('otp').value = '';
    showLoginForm();
    hideOtpForm();
    hideLoadingScreen();
  }

  function readUserProvidedCredentials() {
    const address = document.getElementById('address').value.trim();
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    return { address, username, password };
  }

  function readUserProvidedOtp() {
    const address = document.getElementById('address').value;
    const otp = document.getElementById('otp').value;
    return { address, otp };
  }

  function addLoginSubmitListener(listen) {
    document.getElementById('submit-btn').addEventListener('click', listen);
  }

  function addOtpSubmitListener(listen) {
    document.getElementById('submit-otp-btn').addEventListener('click', listen);
  }

  function addAddressKeyUpListener(listen) {
    document.getElementById('address').addEventListener('keyup', listen);
  }

  function addAddressFocusListener(listen) {
    document.getElementById('address').addEventListener('focus', listen);
  }

  function addAddressBlurListener(listen) {
    document.getElementById('address').addEventListener('blur', listen);
  }

  function addUsernameKeyUpListener(listen) {
    document.getElementById('username').addEventListener('keyup', listen);
  }

  function showError(field, error) {
    clear(field);
    document.getElementById(`${field}`).parentElement.classList.add('invalid');
    document.getElementById(`${field}-error`)?.setAttribute('hide', 'false');
    if (document.getElementById(`${field}-error`))
      document.getElementById(`${field}-error`).innerText = error;
    document
      .getElementById(`${field}-error-icon`)
      ?.setAttribute('hide', 'false');
  }

  function clear(field) {
    document
      .getElementById(`${field}`)
      .parentElement.classList.remove('invalid');
    document.getElementById(`${field}-error`)?.setAttribute('hide', 'true');
    if (document.getElementById(`${field}-error`))
      document.getElementById(`${field}-error`).innerText = '';
    document.getElementById(`${field}-progress`)?.setAttribute('hide', 'true');
    document
      .getElementById(`${field}-error-icon`)
      ?.setAttribute('hide', 'true');
    document
      .getElementById(`${field}-success-icon`)
      ?.setAttribute('hide', 'true');
  }

  function showProgress(field) {
    clear(field);
    document.getElementById(`${field}-progress`)?.setAttribute('hide', 'false');
  }

  function showSuccess(field) {
    clear(field);
    document
      .getElementById(`${field}-success-icon`)
      ?.setAttribute('hide', 'false');
  }

  function updateAddress(address) {
    document.getElementById('address').value = address;
  }

  function getAddressFocusCount() {
    return addressFocusCount;
  }

  function togglePasswordVisibility(event) {
    const icon = event.target;
    if (icon.innerHTML.includes('_off'))
      icon.innerHTML = icon.innerHTML.replace('_off', '');
    else icon.innerHTML += '_off';
    const input = document.getElementById('password');
    input.type = input.type === 'password' ? 'text' : 'password';
    document.getElementById('password').focus();
  }

  return {
    init,
    displayPage,
    resetForm,
    hideLoadingScreen,
    showLoadingScreen,
    showOtpForm,
    hideLoginForm,
    showLoginForm,
    readUserProvidedCredentials,
    readUserProvidedOtp,
    addLoginSubmitListener,
    addOtpSubmitListener,
    addAddressKeyUpListener,
    addAddressFocusListener,
    addAddressBlurListener,
    addUsernameKeyUpListener,
    setLoginColors,
    restoreNavbarColors,
    showError,
    showProgress,
    showSuccess,
    clear,
    updateAddress,
    getAddressFocusCount
  };
}

export { LoginUi };
