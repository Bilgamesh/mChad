import { ThemeUtil } from '../../../utils/theme.js';
import { Languages } from '../../../languages/languages.js';
import { PersistentStore } from '../../../storage/persistent-store.js';

function SettingsActions() {
  const preferencesStore = PersistentStore('app-preferences');
  const themeUtil = ThemeUtil();
  const languages = Languages();

  function toggleLightMode() {
    const mode = this.checked ? 'light' : 'dark';
    preferencesStore.set('mode', mode);
    ui('mode', mode);
    themeUtil.updateBarsByElementColor(
      document.getElementById('navbar-top'),
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
    } catch (err) {
      console.log(
        `[${new Date().toLocaleString()}][settings-actions][toggleNotifications] Error: ${err}`
      );
    }
  }

  function toggleAutorotate() {
    try {
      if (!this.checked) {
        preferencesStore.set('autorotate', false);
        preferencesStore.set('screen-orientation', screen.orientation.type);
        screen.orientation.lock(screen.orientation.type);
        return;
      }
      preferencesStore.set('autorotate', true);
      preferencesStore.del('screen-orientation');
      screen.orientation.unlock();
    } catch (err) {
      console.log(
        `[${new Date().toLocaleString()}][settings-actions][toggleAutorotate] Error: ${err}`
      );
    }
  }

  function toggleHapticFeedback() {
    preferencesStore.set('haptic-feedback', this.checked);
  }

  function toggleTransitionAnimations() {
    preferencesStore.set('transition-animations', this.checked);
    document.getElementById('main-article').classList.remove('page');
    document
      .getElementById('body')
      .setAttribute('transition-animations-disabled', !this.checked);
  }

  async function setColorTheme() {
    preferencesStore.set('theme', this.value);
    await ui('theme', this.value);
    themeUtil.updateBarsByElementColor(
      document.getElementById('navbar-top'),
      '--surface-container'
    );
  }

  function changeLanguage() {
    preferencesStore.set('language', this.value);
    languages.translate();
  }

  return {
    toggleLightMode,
    toggleAutorotate,
    toggleNotifications,
    toggleHapticFeedback,
    toggleTransitionAnimations,
    setColorTheme,
    changeLanguage
  };
}

export { SettingsActions };
