(function () {
  function AppUi({ el, navbar, languages, sleep, PersistentStore }) {
    async function displayPage() {
      el.innerHTML = /* HTML */ `
        <div id="global-blur" class="overlay"></div>
        <dialog id="global-confirm" class="">
          <h5>Default</h5>
          <div>Some text here</div>
          <nav class="right-align no-space">
            <button class="transparent link ripple" translation="CANCEL">
              ${await languages.getTranslation('CANCEL')}
            </button>
            <button class="transparent link ripple" translation="CONFIRM">
              ${await languages.getTranslation('CONFIRM')}
            </button>
          </nav>
        </dialog>

        <dialog id="global-info" class="">
          <h5>
            <span>Default</span>
            <i class="transparent link extra close-icon">close</i>
          </h5>
          <div class="global-info-content">Content here</div>
          <nav class="right-align no-space"></nav>
        </dialog>

        <dialog id="global-input-prompt" class="">
          <h5>Default</h5>
          <pre contenteditable="true" id="global-input-prompt-textarea"></pre>
          <nav class="right-align no-space">
            <button class="transparent link ripple" translation="CANCEL">
              ${await languages.getTranslation('CANCEL')}
            </button>
            <button class="transparent link ripple" translation="CONFIRM">
              ${await languages.getTranslation('CONFIRM')}
            </button>
          </nav>
        </dialog>

        <header id="header-main">
          <nav id="navbar-top">
            <h5 id="navbar-top-title" class="max left-align">mChad</h5>
          </nav>
        </header>

        ${navbar.getHtml()}

        <main class="">
          <div class="main-page" id="main-page"></div>
        </main>

        <div id="notification-msg-0" class="snackbar"></div>
        <div id="notification-msg-1" class="snackbar"></div>

        <div id="error-msg-0" class="snackbar error">
          <div class="max"></div>
          <a class="inverse-link"><i class="error">close</i></a>
        </div>
        <div id="error-msg-1" class="snackbar error">
          <div class="max"></div>
          <a class="inverse-link"><i class="error">close</i></a>
        </div>
      `;

      // Dummy timeout gives browser an overhead to render the page
      await sleep(0);
    }

    return { displayPage };
  }
  window.modules = window.modules || {};
  window.modules.AppUi = AppUi;
})();
