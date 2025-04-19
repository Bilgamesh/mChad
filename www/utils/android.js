import { ThemeUtil } from './theme.js';
import { sleep } from './sleep.js';
import { InMemoryStore } from '../storage/in-memory-store.js';

function AndroidUtil() {
  const store = InMemoryStore('screen-ratios');
  const themeUtil = ThemeUtil();
  const IN_APP_FULL_SCREEN_BROWSER_BG_COLOR = '#0e0e0e';
  const IN_APP_BROWSER_BG_COLOR = '#CCCCCC';
  if (!store.has('originalHeight')) {
    refreshKeyboardDetection();
  }
  const keyboardOnListeners = [];
  const keyboardOffListeners = [];

  // Sudden resize of screen height indicates that keyboard was turned on
  window.addEventListener('resize', () => {
    // Only compare to 80% of the original height to account for inaccuracy resulting from presence of system navigation bar
    const originalHeight = store.get('originalHeight');
    if (window.innerHeight < 0.8 * originalHeight)
      for (const listener of keyboardOnListeners) listener.listen();
    if (window.innerHeight >= 0.8 * originalHeight)
      for (const listener of keyboardOffListeners) listener.listen();
  });

  function refreshKeyboardDetection() {
    store.set('originalHeight', window.innerHeight);
    store.set('originalWidth', window.innerWidth);
  }

  function reverseScreenRatios() {
    const width = store.get('originalHeight');
    store.set('originalHeight', store.get('originalWidth'));
    store.set('originalWidth', width);
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
    NavigationBar.backgroundColorByHexString(
      IN_APP_FULL_SCREEN_BROWSER_BG_COLOR,
      false
    );
    ref.addEventListener('exit', () => {
      themeUtil.updateBarsByElementColor(
        document.getElementById('navbar-top'),
        '--surface-container'
      );
    });
  }

  function openInBrowser(url, target) {
    const ref = cordova.InAppBrowser.open(encodeURI(url), target || '_blank');
    if (target !== '_blank') return;
    // StatusBar.backgroundColorByHexString(IN_APP_BROWSER_BG_COLOR);
    NavigationBar.backgroundColorByHexString(IN_APP_BROWSER_BG_COLOR, true);
    ref.addEventListener('exit', () => {
      themeUtil.updateBarsByElementColor(
        document.getElementById('navbar-top'),
        '--surface-container'
      );
    });
  }

  async function makeStatusBarTransparent() {
    const screenHeightBefore = document.documentElement.clientHeight;
    let screenHeightAfter = screenHeightBefore;
    StatusBar.overlaysWebView(true);
    while (screenHeightAfter === screenHeightBefore) {
      await sleep(10);
      screenHeightAfter = document.documentElement.clientHeight;
    }
    const statusBarHeight = screenHeightAfter - screenHeightBefore;
    document.documentElement.style.setProperty(
      '--status-bar-height',
      statusBarHeight + 'px'
    );
    return statusBarHeight;
  }

  function hasPermission(permission) {
    if (!cordova.plugins.permissions[permission])
      throw 'Such permission does not exist.';
    return new Promise((resolve) => {
      cordova.plugins.permissions.checkPermission(
        cordova.plugins.permissions[permission],
        (status) => resolve(status.hasPermission),
        (err) => {
          console.log(
            `[${new Date().toLocaleString()}][AndroidUtil] Error when checking permission: ${permission}, error: ${err}`
          );
          resolve(false);
        }
      );
    });
  }

  function requestPermission(permission) {
    if (!cordova.plugins.permissions[permission])
      throw 'Such permission does not exist.';
    return new Promise((resolve) => {
      cordova.plugins.permissions.requestPermission(
        cordova.plugins.permissions[permission],
        (status) => resolve(status.hasPermission),
        (err) => {
          console.log(
            `[${new Date().toLocaleString()}][AndroidUtil] Error when requesting permission: ${permission}, error: ${err}`
          );
          resolve(false);
        }
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
    openInBrowser,
    makeStatusBarTransparent,
    refreshKeyboardDetection,
    hasPermission,
    requestPermission,
    reverseScreenRatios
  };
}

export { AndroidUtil };
