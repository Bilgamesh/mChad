import { PersistentStore } from '../../storage/persistent-store.js';
import { SettingsActions } from './scripts/settings-actions.js';
import { SettingsUi } from './scripts/settings-ui.js';

async function Settings({ el, config }) {
  document.getElementById('body').setAttribute('page', 'settings');

  const preferencesStore = PersistentStore('app-preferences');
  const selectedLanguage = preferencesStore.get('language');

  const settingsUi = SettingsUi({
    el,
    config,
    selectedLanguage
  });

  const settingsActions = SettingsActions({
    settingsUi,
    preferencesStore
  });

  await settingsUi.displayPage({
    mode: preferencesStore.get('mode'),
    localNotifications: preferencesStore.get('local-notifications'),
    autorotate: preferencesStore.get('autorotate'),
    transitionAnimations: preferencesStore.get('transition-animations'),
    hapticFeedback: preferencesStore.get('haptic-feedback')
  });

  settingsUi.addHapticFeedbackToggleListener(
    settingsActions.toggleHapticFeedback
  );
  settingsUi.init();
  settingsUi.addColorChangeListener(settingsActions.setColorTheme);
  settingsUi.addLightModeToggleListener(settingsActions.toggleLightMode);
  settingsUi.addLocalNotificationsToggleListener(
    settingsActions.toggleNotifications
  );
  settingsUi.addLanguageMenuChangeListener(settingsActions.changeLanguage);
  settingsUi.addAutorotateToggleListener(settingsActions.toggleAutorotate);
  settingsUi.addTransitionAnimationsToggleListener(
    settingsActions.toggleTransitionAnimations
  );
}

export { Settings };
