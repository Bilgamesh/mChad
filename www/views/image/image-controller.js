(function () {
  async function Image({
    el,
    languages,
    documentUtil,
    animationsUtil,
    themeUtil,
    hapticsUtil,
    router,
    sleep,
    ImageUi
  }) {
    $('#body').setAttribute('page', 'image');

    const encodedUrl = documentUtil.getParam('url');
    const url = atob(encodedUrl);

    const ui = ImageUi({
      el,
      languages,
      url,
      animationsUtil,
      themeUtil,
      hapticsUtil,
      sleep
    });

    await ui.show();

    ui.darkenNavigationBar();

    function onDestroy() {
      ui.hide();
      ui.lightenNavigationBar();
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Image = Image;
})();
