import { PersistentStore } from '../storage/persistent-store.js';

function ThemeUtil() {
  let preferencesStore;

  function updateBarsByElementColor(element, property, darken) {
    preferencesStore = preferencesStore || PersistentStore('app-preferences');
    const mode = preferencesStore.get('mode');
    let color = getComputedStyle(element).getPropertyValue(property);
    if (darken) color = tinycolor.mix(color, '#000000').toHexString();
    NavigationBar.backgroundColorByHexString(color, mode === 'light');
    if (mode === 'dark') StatusBar.styleLightContent();
    else StatusBar.styleDefault();
    return color;
  }

  function getSystemColorMode() {
    return new Promise((resolve) => {
      try {
        cordova.plugins.ThemeDetection.isDarkModeEnabled(
          function (success) {
            resolve(success.value ? 'dark' : 'light');
          },
          function (error) {
            console.log(
              `[${new Date().toLocaleString()}][THEME] Error: ${error}`
            );
            resolve('light');
          }
        );
      } catch (error) {
        console.log(`[${new Date().toLocaleString()}][THEME] Error: ${error}`);
        resolve('light');
      }
    });
  }

  return { updateBarsByElementColor, getSystemColorMode };
}

export { ThemeUtil };
