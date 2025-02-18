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

    function darkenNavigationBar() {
      NavigationBar.backgroundColorByHexString('#000000', false);
    }

    async function show() {
      el.innerHTML = '';
      await sleep(0);
      el.innerHTML = /* HTML */ `<div id="image-view-container">
        <div id="image-view" class="page active">
          <img id="source-image" src="${url}" alt="${url}" />
          <div
            id="controls-bg"
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

      $('#img-reset-btn').addEventListener('click', () => viewer.reset());
      $('#img-back-btn').addEventListener('click', () => window.history.back());
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
      $('#controls-bg').setAttribute('hide', 'false');
      $('#controls').setAttribute('hide', 'false');
      animationsUtil.fadeIn($('#controls-bg'), 500, 0, 1);
      animationsUtil.fadeIn($('#controls'), 500, 0, 1);
    }

    function hideCustomControls() {
      animationsUtil.fadeOut($('#controls-bg'), 500, 0, 1);
      animationsUtil.fadeOut($('#controls'), 500, 0, 1);
      setTimeout(() => {
        $('#controls-bg').setAttribute('hide', !customControlsVisible);
        $('#controls').setAttribute('hide', !customControlsVisible);
      }, 500);
    }

    return { darkenNavigationBar, show, hide, lightenNavigationBar };
  }

  window.modules = window.modules || {};
  window.modules.ImageUi = ImageUi;
})();
