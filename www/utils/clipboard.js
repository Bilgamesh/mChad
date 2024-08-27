(function () {
  function ClipboardUtil() {
    function paste() {
      return new Promise((resolve, reject) => {
        cordova.plugins.clipboard.paste(({ type, error, data }) => {
          if (error) reject(error);
          resolve(data);
        }, reject);
      });
    }

    return { paste };
  }

  function ClipboardUtilBrowser() {
    function paste() {
      return navigator.clipboard.readText();
    }
    return { paste };
  }

  window.modules = window.modules || {};
  window.modules.ClipboardUtil =
    cordova.platformId === 'browser' ? ClipboardUtilBrowser : ClipboardUtil;
})();
