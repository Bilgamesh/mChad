(function () {
  async function Image({
    el,
    documentUtil,
    router,
    sleep,
    ImageUi
  }) {
    $('#body').setAttribute('page', 'image');

    const encodedUrl = documentUtil.getParam('url');
    const url = atob(encodedUrl);

    const ui = ImageUi({ el, url, sleep });

    ui.hideNativeControls();

    await ui.show();

    function onDestroy() {
      ui.showNativeControls();
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Image = Image;
})();
