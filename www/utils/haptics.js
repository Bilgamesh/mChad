(function () {
  function HapticsUtil(PersistentStore) {
    let preferencesStore;
    let enabled = true;

    /* When resuming the app by pressing the shortcut, web view thinks user is performing a long-press
    and triggers haptic feedback. As a workaround to this problem, we can disable haptics when pausing the app
    and re-enable it when user touches anything inside the app, not just the shortcut. */
    document.addEventListener('pause', () => {
      enabled = false;
    });
    document.addEventListener('touchstart', () => {
      enabled = true;
    });

    function tapDefault() {
      if (!enabled) return;
      preferencesStore = preferencesStore || PersistentStore('app-preferences');
      if (
        preferencesStore.get('haptic-feedback') ||
        preferencesStore.get('haptic-feedback') === undefined
      )
        plugins.deviceFeedback.haptic(plugins.deviceFeedback.VIRTUAL_KEY);
    }

    function longPress() {
      if (!enabled) return;
      preferencesStore = preferencesStore || PersistentStore('app-preferences');
      if (
        preferencesStore.get('haptic-feedback') ||
        preferencesStore.get('haptic-feedback') === undefined
      )
        plugins.deviceFeedback.haptic(plugins.deviceFeedback.LONG_PRESS);
    }

    function keyboardTap() {
      if (!enabled) return;
      preferencesStore = preferencesStore || PersistentStore('app-preferences');
      if (
        preferencesStore.get('haptic-feedback') ||
        preferencesStore.get('haptic-feedback') === undefined
      )
        plugins.deviceFeedback.haptic(plugins.deviceFeedback.KEYBOARD_TAP);
    }

    return { tapDefault, longPress, keyboardTap };
  }

  window.modules = window.modules || {};
  window.modules.HapticsUtil = HapticsUtil;
})();
