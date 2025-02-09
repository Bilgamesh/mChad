(function () {
  function LoginUi({
    el,
    sleep,
    animationsUtil,
    hapticsUtil,
    themeUtil,
    languages,
    forumIndex
  }) {
    let addressFocusCount = 0;

    function registerHaptics() {
      $('#back-btn-1').addEventListener('click', hapticsUtil.tapDefault);
      $('#back-btn-1').addEventListener(
        'click',
        animationsUtil.getClickEffect($('#back-btn-1'))
      );
      $('#back-btn-2').addEventListener('click', hapticsUtil.tapDefault);
      $('#back-btn-2').addEventListener(
        'click',
        animationsUtil.getClickEffect($('#back-btn-2'))
      );

      $('#submit-btn').addEventListener('click', (e) => {
        if (cordova.platformId === 'browser') return;
        if (e.screenX !== 0 || e.touches[0].screenX !== 0)
          hapticsUtil.tapDefault();
      });
      $('#submit-btn').addEventListener(
        'click',
        animationsUtil.getClickEffect($('#submit-btn'))
      );
      $('#submit-otp-btn').addEventListener('click', (e) => {
        if (cordova.platformId === 'browser') return;
        if (e.screenX !== 0 || e.touches[0].screenX !== 0)
          hapticsUtil.tapDefault();
      });
      $('#submit-otp-btn').addEventListener(
        'click',
        animationsUtil.getClickEffect($('#submit-otp-btn'))
      );
      $('#pw-visibility-icon').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
    }

    function preventDefaultFormBehavior() {
      $('#login-form').addEventListener('submit', (e) => e.preventDefault());
      $('#otp-form').addEventListener('submi', (e) => e.preventDefault());
    }

    function registerBackButtons() {
      $('#back-btn-1').addEventListener('click', () => history.back());
      $('#back-btn-2').addEventListener('click', () => history.back());
    }

    function init() {
      preventDefaultFormBehavior();
      setLoginColors();
      registerHaptics();
      registerBackButtons();
      addAddressFocusListener(() => {
        addressFocusCount++;
      });
      $('#username').addEventListener('focus', () => clear('username'));
      $('#password').addEventListener('focus', () => clear('password'));
      $('#pw-visibility-icon').addEventListener(
        'click',
        togglePasswordVisibility
      );
    }

    async function displayPage() {
      /* Emptying the page just before re-rendering
      and giving browser an overhead via dummy timeout
      makes BeerCSS transition animations much smoother */
      while (el.firstChild) el.removeChild(el.firstChild);
      await sleep(0);

      el.innerHTML = /* HTML */ `<div class="login-main-page">
        <article
          class="medium middle-align center-align login-article page top active"
        >
          <center id="loading-circle" hide="false">
            <progress class="circle large"></progress>
          </center>
          <center>
            <div id="login-form">
              <form id="login-form-inner" onsubmit="return false">
                <i class="extra">forum</i>
                <h5>${await languages.getTranslation('LOGIN_TITLE')}</h5>
                <br />
                <br />
                <div class="field label border round">
                  <input id="address" type="text" />
                  <label
                    >${await languages.getTranslation('FORUM_ADDRESS')}</label
                  >
                  <span id="address-error" class="error" hide="true"></span>
                  <progress
                    id="address-progress"
                    class="circle small"
                    hide="true"
                  ></progress>
                  <i id="address-error-icon" hide="true">error</i>
                  <i id="address-success-icon" hide="true">check_circle</i>
                </div>

                <div class="field label border round">
                  <input id="username" type="text" />
                  <label>${await languages.getTranslation('USERNAME')}</label>
                  <span id="username-error" class="error" hide="true"></span>
                </div>

                <div class="field label border round">
                  <input id="password" type="password" />
                  <label>${await languages.getTranslation('PASSWORD')}</label>
                  <i id="pw-visibility-icon" class="visibility-icon"
                    >visibility</i
                  >
                  <span id="password-error" class="error" hide="true"> </span>
                </div>
                <br />
                <center>
                  <nav class="center-align">
                    <button
                      id="back-btn-1"
                      class="border open unhoverable"
                      onclick="return false"
                      type="reset"
                      ${forumIndex == 0 ? 'disabled' : ''}
                    >
                      <i>arrow_back</i>
                      <span>${await languages.getTranslation('BACK')}</span>
                    </button>
                    <button
                      id="submit-btn"
                      class="border open unhoverable"
                      type="submit"
                      onclick="return false"
                    >
                      <i>login</i>
                      <span>${await languages.getTranslation('NEXT')}</span>
                    </button>
                  </nav>
                </center>
              </form>
            </div>
            <div id="otp-form" hide="true">
              <form id="otp-form-inner" onsubmit="return false">
                <i class="extra">forum</i>
                <h5>${await languages.getTranslation('LOGIN_TITLE')}</h5>
                <div class="field label border round">
                  <input id="otp" type="number" />
                  <label>${await languages.getTranslation('OTP')}</label>
                  <span id="otp-error" class="error" hide="true"></span>
                </div>
                <br />
                <center>
                  <nav class="center-align">
                    <button
                      id="back-btn-2"
                      class="border open unhoverable"
                      onclick="return false"
                      type="reset"
                    >
                      <i>arrow_back</i>
                      <span>${await languages.getTranslation('BACK')}</span>
                    </button>
                    <button
                      id="submit-otp-btn"
                      class="border open unhoverable"
                      class="login-button"
                      type="text"
                      onclick="return false"
                    >
                      <i>login</i>
                      <span>${await languages.getTranslation('NEXT')}</span>
                    </button>
                  </nav>
                </center>
              </form>
            </div>
          </center>
        </article>
      </div>`;
    }

    function setLoginColors() {
      themeUtil.updateBarsByElementColor(
        $('.login-article')[0],
        '--surface-container-low'
      );
    }

    function restoreNavbarColors() {
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
        '--surface-container'
      );
    }

    function showLoadingScreen() {
      $('#loading-circle').setAttribute('hide', 'false');
    }

    function hideLoadingScreen() {
      $('#loading-circle').setAttribute('hide', 'true');
    }

    function showLoginForm() {
      $('#login-form').setAttribute('hide', 'false');
      $('#login-form').hidden = false;
    }

    function hideLoginForm() {
      $('#login-form').hidden = true;
      $('#login-form').setAttribute('hide', 'true');
    }

    function showOtpForm() {
      $('#otp-form').setAttribute('hide', 'false');
      $('#otp-form').hidden = false;
    }

    function hideOtpForm() {
      $('#otp-form').hidden = true;
      $('#otp-form').setAttribute('hide', 'true');
    }

    function resetForm(full = false) {
      if (full) {
        $('#address').value = '';
        $('#username').value = '';
      }
      $('#password').value = '';
      $('#otp').value = '';
      showLoginForm();
      hideOtpForm();
      hideLoadingScreen();
    }

    function readUserProvidedCredentials() {
      const address = $('#address').value.trim();
      const username = $('#username').value.trim();
      const password = $('#password').value;
      return { address, username, password };
    }

    function readUserProvidedOtp() {
      const address = $('#address').value;
      const otp = $('#otp').value;
      return { address, otp };
    }

    function addLoginSubmitListener(listen) {
      $('#submit-btn').addEventListener('click', listen);
    }

    function addOtpSubmitListener(listen) {
      $('#submit-otp-btn').addEventListener('click', listen);
    }

    function addAddressKeyUpListener(listen) {
      $('#address').addEventListener('keyup', listen);
    }

    function addAddressFocusListener(listen) {
      $('#address').addEventListener('focus', listen);
    }

    function addAddressBlurListener(listen) {
      $('#address').addEventListener('blur', listen);
    }

    function addUsernameKeyUpListener(listen) {
      $('#username').addEventListener('keyup', listen);
    }

    function showError(field, error) {
      clear(field);
      $(`#${field}`).parentElement.classList.add('invalid');
      $(`#${field}-error`)?.setAttribute('hide', 'false');
      if ($(`#${field}-error`)) $(`#${field}-error`).innerText = error;
      $(`#${field}-error-icon`)?.setAttribute('hide', 'false');
    }

    function clear(field) {
      $(`#${field}`).parentElement.classList.remove('invalid');
      $(`#${field}-error`)?.setAttribute('hide', 'true');
      if ($(`#${field}-error`)) $(`#${field}-error`).innerText = '';
      $(`#${field}-progress`)?.setAttribute('hide', 'true');
      $(`#${field}-error-icon`)?.setAttribute('hide', 'true');
      $(`#${field}-success-icon`)?.setAttribute('hide', 'true');
    }

    function showProgress(field) {
      clear(field);
      $(`#${field}-progress`)?.setAttribute('hide', 'false');
    }

    function showSuccess(field) {
      clear(field);
      $(`#${field}-success-icon`)?.setAttribute('hide', 'false');
    }

    function updateAddress(address) {
      $('#address').value = address;
    }

    function getAddressFocusCount() {
      return addressFocusCount;
    }

    function togglePasswordVisibility(event) {
      const icon = event.target;
      if (icon.innerHTML.includes('_off'))
        icon.innerHTML = icon.innerHTML.replace('_off', '');
      else icon.innerHTML += '_off';
      const input = $('#password');
      input.type = input.type === 'password' ? 'text' : 'password';
      $('#password').focus();
    }

    return {
      init,
      displayPage,
      resetForm,
      hideLoadingScreen,
      showLoadingScreen,
      showOtpForm,
      hideLoginForm,
      showLoginForm,
      readUserProvidedCredentials,
      readUserProvidedOtp,
      addLoginSubmitListener,
      addOtpSubmitListener,
      addAddressKeyUpListener,
      addAddressFocusListener,
      addAddressBlurListener,
      addUsernameKeyUpListener,
      setLoginColors,
      restoreNavbarColors,
      showError,
      showProgress,
      showSuccess,
      clear,
      updateAddress,
      getAddressFocusCount
    };
  }

  window.modules = window.modules || {};
  window.modules.LoginUi = LoginUi || LoginUi;
})();
