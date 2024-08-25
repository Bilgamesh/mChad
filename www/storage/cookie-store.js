(function () {
  function CookieStore(browserKey, PersistentStore) {
    let browserStorage;
    let androidKey;

    function init() {
      browserStorage = PersistentStore(`${browserKey}_cookie`);
      androidKey = browserKey.split('/').pop() + '_cookie';
    }

    function set(cookie) {
      if (cordova.platformId === 'browser' || !cordova.plugins.SecureKeyStore)
        browserStorage.set('cookie', cookie);
      else
        return new Promise((resolve, reject) =>
          cordova.plugins.SecureKeyStore.set(
            resolve,
            reject,
            androidKey,
            cookie
          )
        );
    }

    function get() {
      if (cordova.platformId === 'browser' || !cordova.plugins.SecureKeyStore)
        return browserStorage.get('cookie');
      return new Promise((resolve, reject) =>
        cordova.plugins.SecureKeyStore.get(resolve, reject, androidKey)
      );
    }

    function del() {
      if (cordova.platformId === 'browser' || !cordova.plugins.SecureKeyStore)
        browserStorage.del('cookie');
      else
        return new Promise((resolve, reject) =>
          cordova.plugins.SecureKeyStore.remove(resolve, reject, androidKey)
        );
    }

    init();

    return { set, get, del };
  }
  window.modules = window.modules || {};
  window.modules.CookieStore = CookieStore;
})();
