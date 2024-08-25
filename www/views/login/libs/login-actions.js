(function () {
  function LoginActions({
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
  }) {
    let mchatMchatLoginService;
    let loginListener;
    let urlDiscoveryFinished = false;

    async function onLoginClick(e) {
      try {
        if (!(await checkExistingAccounts())) return;
        const { address, username, password } =
          loginUi.readUserProvidedCredentials();
        validateCredentials(address, username, password);
        if (!address || !username || !password || !urlDiscoveryFinished) return;
        e.preventDefault();
        loginUi.hideLoginForm();
        loginUi.showLoadingScreen();
        mchatMchatLoginService = MchatLoginService({
          baseUrl: address,
          urlUtil,
          fetchTool,
          documentUtil
        });
        await mchatMchatLoginService.init();
        await sleep(1000);
        const loginResponse = await mchatMchatLoginService.loginWithCredentials(
          username,
          password
        );
        if (!loginResponse.secondFactorRequired && loginResponse.cookie)
          return onSuccessfullLogin(
            loginResponse.cookie,
            address,
            loginResponse.userId,
            loginResponse.forumName
          );
        if (loginResponse.secondFactorRequired) {
          window.history.pushState(
            { prevHash: window.location.hash },
            '',
            window.location.hash
          );
          loginUi.hideLoadingScreen();
          loginUi.showOtpForm();
          return;
        }
        loginUi.hideLoadingScreen();
        loginUi.showLoginForm();
        popups.showError(await languages.getTranslation('LOGIN_ERROR'));
        return loginUi.resetForm();
      } catch (error) {
        loginUi.resetForm();
        popups.showError(
          `${await languages.getTranslation(
            'LOGIN_ERROR_REASON'
          )}:\n${error.toString()}`
        );
      }
    }

    async function onOTPsubmission(e) {
      try {
        const { address, otp } = loginUi.readUserProvidedOtp();
        validateOtp(otp);
        if (!otp) return;
        e.preventDefault();
        loginUi.showLoadingScreen();
        const otpLoginResponse = await mchatMchatLoginService.loginWithOtp(otp);
        if (otpLoginResponse.cookie)
          return onSuccessfullLogin(
            otpLoginResponse.cookie,
            address,
            otpLoginResponse.userId,
            otpLoginResponse.forumName
          );
        popups.showError(await languages.getTranslation('LOGIN_ERROR'));
        return resetForm();
      } catch (error) {
        window.history.back();
        popups.showError(
          `${await languages.getTranslation(
            'LOGIN_ERROR_REASON'
          )}:\n${error.toString()}`
        );
      }
    }

    async function validateCredentials(address, username, password) {
      if (!address)
        loginUi.showError(
          'address',
          await languages.getTranslation('ADDRESS_CANNOT_BE_EMPTY')
        );
      if (!username)
        loginUi.showError(
          'username',
          await languages.getTranslation('USERNAME_CANNOT_BE_EMPTY')
        );
      if (!password) {
        loginUi.showError(
          'password',
          await languages.getTranslation('PASSWORD_CANNOT_BE_EMPTY')
        );
      }
    }

    async function validateOtp(otp) {
      if (!otp)
        loginUi.showError(
          'otp',
          await languages.getTranslation('OTP_CANNOT_BE_EMPTY')
        );
    }

    async function checkExistingAccounts() {
      const { address, username } = loginUi.readUserProvidedCredentials();
      const name = urlUtil.convertUrlToName(address);
      for (const forum of forums) {
        const forumStorage = PersistentStore(
          `${forum.address}_${forum.userId}`
        );
        const profile = forumStorage.get('profile');
        if (
          profile &&
          forum.name === name &&
          profile.username.toLowerCase() === username.toLowerCase()
        ) {
          loginUi.showError(
            'username',
            await languages.getTranslation('ALREADY_LOGGED_IN')
          );
          return false;
        }
      }
      loginUi.clear('username');
      return true;
    }

    function onSuccessfullLogin(cookie, address, userId, forumName) {
      if (loginListener)
        loginListener.listen({ address, userId, cookie, forumName });
    }

    function addLoginListener(listen) {
      loginListener = { listen };
    }

    async function startUrlDiscovery() {
      const { address } = loginUi.readUserProvidedCredentials();
      if (address === '') return;
      loginUi.showProgress('address');
      const addressFocusCount = loginUi.getAddressFocusCount();
      const originalHash = window.location.hash;
      const urls = urlUtil.getAllUrlPermutations(address);
      if (urls.includes('https://wykop.pl'))
        return stopUrlDiscovery('failure', 'spierdalaj z tym <brawo>');
      const url = await discoverUrl(
        urls,
        () =>
          addressFocusCount !== loginUi.getAddressFocusCount() ||
          window.location.hash !== originalHash
        // abort the URL discovery if user has performed any action on the address bar or left the login page and came back
      );
      if (url === -1) return;
      if (url) {
        loginUi.updateAddress(url);
        await stopUrlDiscovery('success');
        return;
      }
      await stopUrlDiscovery('failure');
    }

    async function discoverUrl(urls, shouldAbort) {
      for (const url of urls) {
        if (shouldAbort()) return -1;
        try {
          mchatMchatLoginService = MchatLoginService({
            baseUrl: url,
            urlUtil,
            fetchTool,
            documentUtil
          });
          await mchatMchatLoginService.init();
          return url;
        } catch (err) {
          console.log(err);
        }
      }
    }

    async function stopUrlDiscovery(status, easterEgg) {
      switch (status) {
        case 'success':
          loginUi.showSuccess('address');
          urlDiscoveryFinished = true;
          break;
        case 'failure':
          if (easterEgg) loginUi.showError('address', easterEgg);
          else
            loginUi.showError(
              'address',
              await languages.getTranslation('FORUM_NOT_RECOGNIZED')
            );
          urlDiscoveryFinished = false;
          break;
        default:
          loginUi.clear('address');
          urlDiscoveryFinished = false;
          break;
      }
    }

    return {
      onLoginClick,
      onOTPsubmission,
      addLoginListener,
      checkExistingAccounts,
      startUrlDiscovery,
      stopUrlDiscovery
    };
  }

  window.modules = window.modules || {};
  window.modules.LoginActions = LoginActions || LoginActions;
})();
