(function () {
  function ImageUi({ el, url, themeUtil, sleep }) {
    function hideNativeControls() {
      StatusBar.backgroundColorByHexString('#000000');
      NavigationBar.backgroundColorByHexString('#000000', false);
      StatusBar.hide();
      NavigationBar.hide();
    }

    async function show() {
      el.innerHTML = '';
      await sleep(0);
      el.innerHTML = /* HTML */ `<div id="image-view-container">
        <div id="image-view" class="page active">
          <img id="source-image" src="${url}" alt="${url}" />
        </div>
      </div>`;

      new Viewer($('#source-image'), {
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
      }).show();
    }

    function showNativeControls() {
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
        '--surface-container'
      );
      StatusBar.show();
      NavigationBar.show();
    }

    function onCanvasClick() {}

    function toggleControls() {}

    return { hideNativeControls, show, showNativeControls };
  }

  window.modules = window.modules || {};
  window.modules.ImageUi = ImageUi;
})();
