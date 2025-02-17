(function () {
  async function Image({
    el,
    languages,
    documentUtil,
    animationsUtil,
    hapticsUtil,
    router,
    sleep,
    ImageUi
  }) {
    $('#body').setAttribute('page', 'image');

    const encodedUrl = documentUtil.getParam('url');
    const url = atob(encodedUrl);

    const ui = ImageUi({ el, languages, url, animationsUtil, hapticsUtil, sleep });

    await ui.show();

    ui.hideNativeControls();

    async function onDestroy() {
      ui.hide();
      await ui.showNativeControls();
      /* Give Android time to re-scale the viewport
      after the control panels are restored before switching to new view */
      await sleep(100);
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Image = Image;
})();
