(function () {
  function ThemeUtil(PersistentStore) {
    let preferencesStore;

    function updateBarsByElementColor(element, property) {
      preferencesStore = preferencesStore || PersistentStore('app-preferences');
      const mode = preferencesStore.get('mode');
      const color = getComputedStyle(element).getPropertyValue(property);
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
