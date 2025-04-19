import { Languages } from '../../../languages/languages.js';
import { AnimationsUtil } from '../../../utils/animations.js';
import { HapticsUtil } from '../../../utils/haptics.js';
import { ThemeUtil } from '../../../utils/theme.js';
import { sleep } from '../../../utils/sleep.js';

function ImageUi({ el, url }) {
  const themeUtil = ThemeUtil();
  const languages = Languages();
  const animationsUtil = AnimationsUtil();
  const hapticsUtil = HapticsUtil();

  let customControlsVisible = false;
  let viewer;

  const downloadListeners = [];

  function darkenNavigationBar() {
    NavigationBar.backgroundColorByHexString('#000000', false);
    StatusBar.styleLightContent();
  }

  async function show() {
    el.innerHTML = '';
    document.getElementById('body').setAttribute('page', 'image');
    await sleep(0);
    el.innerHTML = /* HTML */ `<div id="image-view-container">
      <div id="image-view" class="page active">
        <div
          id="controls-bg-top"
          class="top-shadow"
          hide="true"
          style="opacity: 0"
        ></div>
        <img id="source-image" src="${url}" alt="${url}" />
        <div
          id="controls-bg-bottom"
          class="bottom-shadow"
          hide="true"
          style="opacity: 0"
        ></div>
        <div id="controls" hide="true" style="opacity: 0">
          <a id="img-back-btn">
            <i>arrow_back</i>
            <div>${await languages.getTranslation('BACK')}</div>
          </a>
          <a id="img-reset-btn">
            <i>history</i>
            <div>${await languages.getTranslation('RESET')}</div>
          </a>
          <a id="img-download-btn">
            <i>download</i>
            <div>${await languages.getTranslation('DOWNLOAD')}</div>
          </a>
        </div>
      </div>
    </div>`;

    viewer = new Viewer(document.getElementById('source-image'), {
      title: false,
      inline: true,
      toolbar: false,
      navbar: false,
      tooltip: false,
      toggleOnDblclick: false,
      transition: false,
      button: false,
      rotatable: false,
      backdrop: false,
      viewed: () => {
        document
          .querySelectorAll('.viewer-canvas')[0]
          .addEventListener('click', onCanvasClick);
      }
    });
    viewer.show();
    toggleControls();
    addListeners();
  }

  function addListeners() {
    document
      .getElementById('img-back-btn')
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById('img-reset-btn')
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById('img-download-btn')
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById('img-download-btn')
      .addEventListener('click', onDownload);
    document
      .getElementById('img-reset-btn')
      .addEventListener('click', () => viewer.reset());
    document
      .getElementById('img-back-btn')
      .addEventListener('click', () => window.history.back());
  }

  function onDownload() {
    for (const listener of downloadListeners) listener.listen(url);
  }

  function hide() {
    document.getElementsByClassName('viewer-canvas')[0].remove();
    document.getElementById('image-view').remove();
  }

  function lightenNavigationBar() {
    themeUtil.updateBarsByElementColor(
      document.getElementById('navbar-top'),
      '--surface-container'
    );
  }

  function onCanvasClick() {
    toggleControls();
  }

  function toggleControls() {
    if (customControlsVisible) hideCustomControls();
    else showCustomControls();
    customControlsVisible = !customControlsVisible;
  }

  function showCustomControls() {
    document.getElementById('controls-bg-top').setAttribute('hide', 'false');
    document.getElementById('controls-bg-bottom').setAttribute('hide', 'false');
    document.getElementById('controls').setAttribute('hide', 'false');
    animationsUtil.fadeIn(
      document.getElementById('controls-bg-top'),
      500,
      0,
      1
    );
    animationsUtil.fadeIn(
      document.getElementById('controls-bg-bottom'),
      500,
      0,
      1
    );
    animationsUtil.fadeIn(document.getElementById('controls'), 500, 0, 1);
  }

  function hideCustomControls() {
    animationsUtil.fadeOut(
      document.getElementById('controls-bg-top'),
      500,
      0,
      1
    );
    animationsUtil.fadeOut(
      document.getElementById('controls-bg-bottom'),
      500,
      0,
      1
    );
    animationsUtil.fadeOut(document.getElementById('controls'), 500, 0, 1);
    setTimeout(() => {
      document
        .getElementById('controls-bg-top')
        .setAttribute('hide', !customControlsVisible);
      document
        .getElementById('controls-bg-bottom')
        .setAttribute('hide', !customControlsVisible);
      document
        .getElementById('controls')
        .setAttribute('hide', !customControlsVisible);
    }, 500);
  }

  function addDownloadListener(listen) {
    const id = crypto.randomUUID();
    downloadListeners.push({ id, listen });
    return id;
  }

  return {
    darkenNavigationBar,
    show,
    hide,
    lightenNavigationBar,
    addDownloadListener
  };
}

export { ImageUi };
