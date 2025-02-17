(function () {
  async function Image({
    el,
    documentUtil,
    themeUtil,
    router,
    sleep,
    ImageUi
  }) {
    $('#body').setAttribute('page', 'image');

    const encodedUrl = documentUtil.getParam('url');
    const url = atob(encodedUrl);

    const ui = ImageUi({ el, url, themeUtil, sleep });

    await ui.show();

    ui.hideNativeControls();

    function onDestroy() {
      ui.showNativeControls();
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Image = Image;
})();
