(function () {
  function SettingsActions({
    languages,
    preferencesStore,
    themeUtil
  }) {
    function toggleLightMode() {
      const mode = this.checked ? 'light' : 'dark';
      preferencesStore.set('mode', mode);
      ui('mode', mode);
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
        '--surface-container'
      );
    }

    function toggleNotifications() {
      const _this = this;
      try {
        if (!_this.checked) {
          preferencesStore.set('local-notifications', false);
          return;
        }
        cordova.plugins.notification.local.requestPermission((granted) => {
          _this.checked = !!granted;
          preferencesStore.set('local-notifications', granted);
        });
      } catch (err) {}
    }

    function toggleHapticFeedback() {
      preferencesStore.set('haptic-feedback', this.checked);
    }

    async function setColorTheme() {
      preferencesStore.set('theme', this.value);
      await ui('theme', this.value);
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
        '--surface-container'
      );
    }

    function changeLanguage() {
      preferencesStore.set('language', this.value);
      languages.translate();
    }

    return {
      toggleLightMode,
      toggleNotifications,
      toggleHapticFeedback,
      setColorTheme,
      changeLanguage
    };
  }
  window.modules = window.modules || {};
  window.modules.SettingsActions = SettingsActions;
})();
