import { AndroidUtil } from '../../utils/android.js';
import { DocumentUtil } from '../../utils/document.js';
import { ImageUi } from './scripts/image-ui.js';
import { sleep } from '../../utils/sleep.js';
import { Languages } from '../../languages/languages.js';

async function Image({ el, router, popups }) {
  const androidUtil = AndroidUtil();
  const documentUtil = DocumentUtil();
  const languages = Languages();

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
    url,
    sleep
  });

  await ui.show();

  ui.darkenNavigationBar();

  ui.addDownloadListener(async (url) => {
    /* Android 11+ does not require permission to create files in Downloads folder.
      Permission has to be requested for older versions. */
    if (+device.sdkVersion <= 28) {
      let hasPermission = await androidUtil.hasPermission(
        'WRITE_EXTERNAL_STORAGE'
      );
      if (!hasPermission)
        hasPermission = androidUtil.requestPermission('WRITE_EXTERNAL_STORAGE');
      if (!hasPermission) return;
    }
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
        popups.showError(`${imageSavedErrorMessage}:\n${JSON.stringify(err)}`);
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

export { Image };
