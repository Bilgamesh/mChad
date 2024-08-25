(function () {
  async function Login({
    el,
    languages,
    PersistentStore,
    globalSynchronizer,
    documentUtil,
    router,
    animationsUtil,
    hapticsUtil,
    sleep,
    LoginUi,
    themeUtil,
    LoginActions,
    MchatLoginService,
    urlUtil,
    fetchTool,
    CookieStore,
    popups
  }) {
    const DEFAULT_FORUM_INDEX = '0';
    const forumIndex =
      documentUtil.getParam('forumIndex') || DEFAULT_FORUM_INDEX;

    $('#body').setAttribute('page', 'login');

    const loginUi = LoginUi({
      el,
      sleep,
      animationsUtil,
      hapticsUtil,
      themeUtil,
      languages,
      forumIndex
    });

    await loginUi.displayPage();

    const globalStorage = PersistentStore('*');
    const forums = globalStorage.get('forums') || [];

    const loginActions = LoginActions({
      loginUi,
      forums,
      MchatLoginService,
      urlUtil,
      PersistentStore,
      languages,
      fetchTool,
      sleep,
      popups,
      documentUtil
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
  window.modules = window.modules || {};
  window.modules.Login = Login;
})();
