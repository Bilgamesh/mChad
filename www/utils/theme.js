(function () {
  function ThemeUtil(PersistentStore) {
    let preferencesStore;

    function updateBarsByElementColor(element, property, darken) {
      preferencesStore = preferencesStore || PersistentStore('app-preferences');
      const mode = preferencesStore.get('mode');
      let color = getComputedStyle(element).getPropertyValue(property);
      if (darken) color = tinycolor.mix(color, '#000000').toHexString();
      StatusBar.backgroundColorByHexString(color);
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
          console.log(
            `[${new Date().toLocaleString()}][THEME] Error: ${error}`
          );
          resolve('light');
        }
      });
    }

    return { updateBarsByElementColor, getSystemColorMode };
  }
  window.modules = window.modules || {};
  window.modules.ThemeUtil = ThemeUtil;
})();
