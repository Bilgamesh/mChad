import { PersistentStore } from '../../storage/persistent-store.js';
import { DocumentUtil } from '../../utils/document.js';
import { CookieStore } from '../../storage/cookie-store.js';
import { LoginActions } from './scripts/login-actions.js';
import { LoginUi } from './scripts/login-ui.js';

async function Login({ el, globalSynchronizer, router, fetchTool, popups }) {
  const DEFAULT_FORUM_INDEX = '0';
  const documentUtil = DocumentUtil();
  const forumIndex = documentUtil.getParam('forumIndex') || DEFAULT_FORUM_INDEX;

  document.getElementById('body').setAttribute('page', 'login');

  const loginUi = LoginUi({
    el,
    forumIndex
  });

  await loginUi.displayPage();

  const globalStorage = PersistentStore('*');
  const forums = globalStorage.get('forums') || [];

  const loginActions = LoginActions({
    loginUi,
    forums,
    fetchTool,
    popups
  });

  if (forums[forumIndex]) return router.redirect('#chat');

  loginUi.init();

  loginUi.addLoginSubmitListener(loginActions.onLoginClick);
  loginUi.addOtpSubmitListener(loginActions.onOTPsubmission);
  loginUi.addAddressKeyUpListener(loginActions.checkExistingAccounts);
  loginUi.addAddressFocusListener(loginActions.stopUrlDiscovery);
  loginUi.addAddressBlurListener(loginActions.startUrlDiscovery);
  loginUi.addUsernameKeyUpListener(loginActions.checkExistingAccounts);

  loginActions.addLoginListener(onSuccessfulLogin);

  loginUi.hideLoadingScreen();

  async function onSuccessfulLogin({ address, userId, cookie, forumName }) {
    rememberForum(address, userId, forumName);
    await CookieStore(`${address}_${userId}`, PersistentStore).set(cookie);
    loginUi.hideLoadingScreen();
    router.redirect(`#chat?forumIndex=${forumIndex}`);
    globalSynchronizer.restartSync();
  }

  function rememberForum(address, userId, name) {
    const index = globalStorage.add('forums', { address, userId, name }) - 1;
    return index;
  }

  function onDestroy() {
    loginUi.restoreNavbarColors();
  }

  router.addOnDestroy(onDestroy);
}

export { Login };
