import { InMemoryStore } from '../storage/in-memory-store.js';
import { PersistentStore } from '../storage/persistent-store.js';

/**
 * @returns {{ tapDefault: () => void, longPress: () => void, keyboardTap: () => void }}
 */
function HapticsUtil() {
  const cache = InMemoryStore('haptics-util');
  if (cache.has('haptics-util')) return cache.get('haptics-util');
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

  const util = { tapDefault, longPress, keyboardTap };

  cache.set('haptics-util', util);

  return util;
}

export { HapticsUtil };
