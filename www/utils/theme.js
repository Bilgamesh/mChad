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

    return { updateBarsByElementColor };
  }
  window.modules = window.modules || {};
  window.modules.ThemeUtil = ThemeUtil;
})();
