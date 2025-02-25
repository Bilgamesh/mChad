(function () {
  function ImageUi({
    el,
    languages,
    url,
    animationsUtil,
    themeUtil,
    hapticsUtil,
    sleep
  }) {
    let customControlsVisible = false;
    let viewer;

    const downloadListeners = [];

    function darkenNavigationBar() {
      NavigationBar.backgroundColorByHexString('#000000', false);
      StatusBar.styleLightContent();
    }

    async function show() {
      el.innerHTML = '';
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

      viewer = new Viewer($('#source-image'), {
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
          $('.viewer-canvas')[0].addEventListener('click', onCanvasClick);
        }
      });
      viewer.show();
      toggleControls();
      addListeners();
    }

    function addListeners() {
      $('#img-back-btn').addEventListener('click', hapticsUtil.tapDefault);
      $('#img-reset-btn').addEventListener('click', hapticsUtil.tapDefault);
      $('#img-download-btn').addEventListener('click', hapticsUtil.tapDefault);
      $('#img-download-btn').addEventListener('click', onDownload);
      $('#img-reset-btn').addEventListener('click', () => viewer.reset());
      $('#img-back-btn').addEventListener('click', () => window.history.back());
    }

    function onDownload() {
      for (const listener of downloadListeners) listener.listen(url);
    }

    function hide() {
      $('.viewer-canvas')[0].remove();
      $('#image-view').remove();
    }

    function lightenNavigationBar() {
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
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
      $('#controls-bg-top').setAttribute('hide', 'false');
      $('#controls-bg-bottom').setAttribute('hide', 'false');
      $('#controls').setAttribute('hide', 'false');
      animationsUtil.fadeIn($('#controls-bg-top'), 500, 0, 1);
      animationsUtil.fadeIn($('#controls-bg-bottom'), 500, 0, 1);
      animationsUtil.fadeIn($('#controls'), 500, 0, 1);
    }

    function hideCustomControls() {
      animationsUtil.fadeOut($('#controls-bg-top'), 500, 0, 1);
      animationsUtil.fadeOut($('#controls-bg-bottom'), 500, 0, 1);
      animationsUtil.fadeOut($('#controls'), 500, 0, 1);
      setTimeout(() => {
        $('#controls-bg-top').setAttribute('hide', !customControlsVisible);
        $('#controls-bg-bottom').setAttribute('hide', !customControlsVisible);
        $('#controls').setAttribute('hide', !customControlsVisible);
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

  window.modules = window.modules || {};
  window.modules.ImageUi = ImageUi;
})();
