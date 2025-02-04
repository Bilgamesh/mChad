(function () {
  function AndroidUtil(themeUtil) {
    const IN_APP_FULL_SCREEN_BROWSER_BG_COLOR = '#0e0e0e';
    const IN_APP_BROWSER_BG_COLOR = '#CCCCCC';
    let originalHeight = window.innerHeight;
    const keyboardOnListeners = [];
    const keyboardOffListeners = [];

    window.addEventListener('resize', () => {
      if (window.innerHeight < originalHeight)
        for (const listener of keyboardOnListeners) listener.listen();
      if (window.innerHeight >= originalHeight)
        for (const listener of keyboardOffListeners) listener.listen();
    });

    function refreshKeyboardDetection() {
      originalHeight = window.innerHeight;
    }

    function hideKeyboard(element) {
      element.setAttribute('readonly', 'readonly'); // Force keyboard to hide on input field.
      element.setAttribute('disabled', 'true'); // Force keyboard to hide on textarea field.
      setTimeout(function () {
        element.blur(); //actually close the keyboard
        // Remove readonly attribute after keyboard is hidden.
        element.removeAttribute('readonly');
        element.removeAttribute('disabled');
      }, 100);
    }

    function addKeyboardOnListener(listen) {
      refreshKeyboardDetection();
      const id = crypto.randomUUID();
      keyboardOnListeners.push({ listen, id });
      return id;
    }

    function removeKeyboardOnListener(id) {
      const index = keyboardOnListeners.findIndex(
        (listener) => listener.id === id
      );
      if (index !== -1) keyboardOnListeners.splice(index, 1);
    }

    function addKeyboardOffListener(listen) {
      const id = crypto.randomUUID();
      keyboardOffListeners.push({ listen, id });
      return id;
    }

    function removeKeyboardOffListener(id) {
      const index = keyboardOffListeners.findIndex(
        (listener) => listener.id === id
      );
      if (index !== -1) keyboardOffListeners.splice(index, 1);
    }

    function openInFullScreenBrowser(url) {
      const ref = cordova.InAppBrowser.open(
        encodeURI(url),
        '_blank',
        'location=no'
      );
      StatusBar.backgroundColorByHexString(IN_APP_FULL_SCREEN_BROWSER_BG_COLOR);
      NavigationBar.backgroundColorByHexString(
        IN_APP_FULL_SCREEN_BROWSER_BG_COLOR,
        false
      );
      ref.addEventListener('exit', () => {
        themeUtil.updateBarsByElementColor(
          $('#navbar-top'),
          '--surface-container'
        );
      });
    }

    function openInBrowser(url, target) {
      const ref = cordova.InAppBrowser.open(encodeURI(url), target || '_blank');
      if (target !== '_blank') return;
      StatusBar.backgroundColorByHexString(IN_APP_BROWSER_BG_COLOR);
      NavigationBar.backgroundColorByHexString(IN_APP_BROWSER_BG_COLOR, true);
      ref.addEventListener('exit', () => {
        themeUtil.updateBarsByElementColor(
          $('#navbar-top'),
          '--surface-container'
        );
      });
    }

    return {
      hideKeyboard,
      addKeyboardOnListener,
      addKeyboardOffListener,
      removeKeyboardOnListener,
      removeKeyboardOffListener,
      openInFullScreenBrowser,
      openInBrowser
    };
  }

  window.modules = window.modules || {};
  window.modules.AndroidUtil = AndroidUtil;
})();
