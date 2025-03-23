(function () {
  async function Settings({
    el,
    languages,
    PersistentStore,
    hapticsUtil,
    sleep,
    themeUtil,
    SettingsUi,
    SettingsActions,
    config
  }) {
    $('#body').setAttribute('page', 'settings');

    const preferencesStore = PersistentStore('app-preferences');
    const selectedLanguage = preferencesStore.get('language');

    const settingsUi = SettingsUi({
      el,
      hapticsUtil,
      languages,
      config,
      selectedLanguage,
      sleep
    });

    const settingsActions = SettingsActions({
      languages,
      settingsUi,
      preferencesStore,
      themeUtil
    });

    await settingsUi.displayPage({
      mode: preferencesStore.get('mode'),
      localNotifications: preferencesStore.get('local-notifications'),
      autorotate: preferencesStore.get('autorotate'),
      hapticFeedback: preferencesStore.get('haptic-feedback')
    });

    settingsUi.addHapticFeedbackToggleListener(settingsActions.toggleHapticFeedback);
    settingsUi.init();
    settingsUi.addColorChangeListener(settingsActions.setColorTheme);
    settingsUi.addLightModeToggleListener(settingsActions.toggleLightMode);
    settingsUi.addLocalNotificationsToggleListener(settingsActions.toggleNotifications);
    settingsUi.addLanguageMenuChangeListener(settingsActions.changeLanguage);
    settingsUi.addAutorotateToggleListener(settingsActions.toggleAutorotate);

  }

  window.modules = window.modules || {};
  window.modules.Settings = Settings;
})();
