(function () {
  function Popups(hapticsUtil, documentUtil, themeUtil) {
    $('#error-msg-0').addEventListener('click', hideError);
    $('#error-msg-1').addEventListener('click', hideError);
    $('#notification-msg-0').addEventListener('click', hideNotification);
    $('#notification-msg-1').addEventListener('click', hideNotification);
    $('#global-blur').addEventListener('click', hideConfirmationBox);
    $('#global-blur').addEventListener('click', hideInfoBox);

    let errorMsgIndex = 0;
    let notificationMsgIndex = 0;
    let notificationTimeout;

    function showNotification(message, expiresInMs = 3 * 1000) {
      hideNotification();
      clearTimeout(notificationTimeout);
      if (expiresInMs)
        notificationTimeout = setTimeout(hideNotification, expiresInMs);
      notificationMsgIndex = +!notificationMsgIndex;
      if (
        $(`#notification-msg-${notificationMsgIndex}`).classList.contains(
          'active'
        )
      )
        return;
      $(`#notification-msg-${notificationMsgIndex}`).classList.add('active');
      $(`#notification-msg-${notificationMsgIndex}`).innerText = message;
    }

    function hideNotification() {
      $(`#notification-msg-${notificationMsgIndex}`).classList.remove('active');
      const [textDiv] = $(`#error-msg-${notificationMsgIndex}`).children;
      textDiv.innerText = '';
    }

    function showError(message) {
      hideError();
      errorMsgIndex = +!errorMsgIndex;
      if ($(`#error-msg-${errorMsgIndex}`).classList.contains('active')) return;
      const [textDiv] = $(`#error-msg-${errorMsgIndex}`).children;
      $(`#error-msg-${errorMsgIndex}`).classList.add('active');
      textDiv.innerText = message;
    }

    function hideError() {
      $(`#error-msg-${errorMsgIndex}`).classList.remove('active');
      const [textDiv] = $(`#error-msg-${errorMsgIndex}`).children;
      textDiv.innerText = '';
    }

    function showConfirmationBox({ title, text, onConfirm }) {
      $('#global-confirm').children[0].innerText = title || 'Default';
      $('#global-confirm').children[1].innerText = text || 'Some text here';
      $('#global-confirm').children[2].children[0].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      $('#global-confirm').children[2].children[1].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      $('#global-confirm').children[2].children[0].addEventListener(
        'click',
        hideConfirmationBox
      );
      $('#global-confirm').children[2].children[1].addEventListener(
        'click',
        () => {
          hideConfirmationBox();
          onConfirm();
        }
      );
      document.addEventListener('backbutton', hideConfirmationBox);
      $('#global-confirm').classList.add('active');
      $('#global-blur').classList.add('active');
      darkenUi();
    }

    function showInfoBox({ title, content }) {
      $('#global-info').children[0].children[0].innerText = title || 'Default';
      $('#global-info').children[1].innerHTML = content;
      $('#global-info').children[0].children[1].addEventListener(
        'click',
        hideInfoBox
      );
      $('#global-info').children[0].children[1].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      document.addEventListener('backbutton', hideInfoBox);
      $('#global-info').classList.add('active');
      $('#global-blur').classList.add('active');
      darkenUi();
    }

    function hideConfirmationBox() {
      $('#global-confirm').classList.remove('active');
      $('#global-blur').classList.remove('active');
      documentUtil.removeAllListeners($('#global-confirm'));
      document.removeEventListener('backbutton', hideConfirmationBox);
      lightenUi();
    }

    function hideInfoBox() {
      $('#global-info').classList.remove('active');
      $('#global-blur').classList.remove('active');
      documentUtil.removeAllListeners($('#global-info'));
      document.removeEventListener('backbutton', hideInfoBox);
      lightenUi();
    }

    function darkenUi() {
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
        '--surface-container',
        true
      );
    }

    function lightenUi() {
      themeUtil.updateBarsByElementColor(
        $('#navbar-top'),
        '--surface-container',
        false
      );
    }

    return {
      showError,
      showInfoBox,
      hideError,
      hideInfoBox,
      showConfirmationBox,
      showNotification
    };
  }
  window.modules = window.modules || {};
  window.modules.Popups = Popups;
})();
