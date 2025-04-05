(function () {
  async function Config(PersistentStore, themeUtil) {
    const USE_PROXY = cordova.platformId === 'browser';
    const PROXY_URL = 'http://localhost:3000';
    const SYNC_INTERVAL_MS = 5000;
    const DEFAULT_USER_AGENT =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
    const DEFAULT_MODE = 'dark';
    const DEFAULT_THEME = '#FFFFFF';
    const DEFAULT_LANGUAGE = 'en-US';
    const DEFAULT_FORUM_INDEX = '0';
    const SUPPORTED_LANGUAGES = [
      { name: 'ENGLISH', code: 'en-US' },
      { name: 'POLISH', code: 'pl-PL' }
    ];
    const MAX_MESSAGE_AMOUNT = 50;
    const MAX_NOTIFICATION_MESSAGES = 4;

    const preferencesStore = PersistentStore('app-preferences');
    const language =
      preferencesStore.get('language') ||
      navigator.language ||
      DEFAULT_LANGUAGE;
    preferencesStore.set('language', language);
    const mode =
      preferencesStore.get('mode') ||
      (await themeUtil.getSystemColorMode()) ||
      DEFAULT_MODE;
    preferencesStore.set('mode', mode);
    const theme = preferencesStore.get('theme') || DEFAULT_THEME;
    preferencesStore.set('theme', theme);
    let autorotate = preferencesStore.get('autorotate');
    if (autorotate === undefined) autorotate = true;
    preferencesStore.set('autorotate', autorotate);
    if (autorotate) screen.orientation.unlock();
    else screen.orientation.lock(screen.orientation.type);
    let transitionAnimations = preferencesStore.get('transition-animations');
    if (transitionAnimations === undefined) transitionAnimations = true;
    preferencesStore.set('transition-animations', transitionAnimations);
    $('#body').setAttribute('transition-animations-disabled', !transitionAnimations);
    cordova.plugins.notification.local.hasPermission((granted) => {
      if (!granted) preferencesStore.set('local-notifications', false);
    });
    ui('mode', mode);
    await ui('theme', theme);
    const NAVBAR_COLOR = themeUtil.updateBarsByElementColor(
      $('#navbar-top'),
      '--surface-container'
    );

    console.log(
      `[${new Date().toLocaleString()}][Config] Android SDK version: ${
        device.sdkVersion
      }`
    );
    console.log(
      `[${new Date().toLocaleString()}][Config] Language: ${language}`
    );
    console.log(`[${new Date().toLocaleString()}][Config] Mode: ${mode}`);
    console.log(`[${new Date().toLocaleString()}][Config] Theme: ${theme}`);
    console.log(
      `[${new Date().toLocaleString()}][Config] Local notifications: ${preferencesStore.get(
        'local-notifications'
      )}`
    );
    console.log(
      `[${new Date().toLocaleString()}][Config] Haptics: ${preferencesStore.get(
        'haptic-feedback'
      )}`
    );

    const config = {
      USE_PROXY,
      PROXY_URL,
      SYNC_INTERVAL_MS,
      DEFAULT_LANGUAGE,
      DEFAULT_USER_AGENT,
      SUPPORTED_LANGUAGES,
      DEFAULT_THEME,
      DEFAULT_MODE,
      NAVBAR_COLOR,
      DEFAULT_FORUM_INDEX,
      MAX_MESSAGE_AMOUNT,
      MAX_NOTIFICATION_MESSAGES
    };

    console.log(
      `[${new Date().toLocaleString()}][Config] Variables: ${JSON.stringify(
        config
      )}`
    );

    return config;
  }

  window.modules = window.modules || {};
  window.modules.Config = Config;
})();
