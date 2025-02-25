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
    ImageUi,
    popups
  }) {
    $('#body').setAttribute('page', 'image');

    const imageExtensions = [
      'png',
      'jpg',
      'jpeg',
      'gif',
      'apng',
      'avif',
      'svg',
      'webp'
    ];

    const imageSavedMessage = await languages.getTranslation('IMAGE_SAVED');
    const imageSavedErrorMessage = await languages.getTranslation(
      'IMAGE_SAVED_ERROR'
    );

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

    ui.addDownloadListener((url) => {
      const filename = getFileName(url);
      const path = cordova.file.externalRootDirectory + 'download/' + filename;
      console.log(
        `[${new Date().toLocaleString()}][IMAGE-CONTROLLER] Saving image: ${url}, as: ${path}`
      );
      cordova.plugin.http.downloadFile(
        url,
        {},
        {},
        path,
        () => popups.showNotification(`${imageSavedMessage}:\n${filename}`),
        (err) => {
          console.log(
            `[${new Date().toLocaleString()}][IMAGE-CONTROLLER] Error when downloading image: ${err}, url: ${url}`
          );
          popups.showError(
            `${imageSavedErrorMessage}:\n${JSON.stringify(err)}`
          );
        }
      );
    });

    function getFileName(url) {
      const originalFileName = url.split('?')[0].split('/').pop().toLowerCase();
      let extension = originalFileName.split('.').pop();
      if (!imageExtensions.includes(extension)) extension = 'png';
      return new Date().getTime() + '.' + extension;
    }

    function onDestroy() {
      ui.hide();
      ui.lightenNavigationBar();
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Image = Image;
})();
