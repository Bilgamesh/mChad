import { ThemeUtil } from '../../../utils/theme.js';
import { HapticsUtil } from '../../../utils/haptics.js';
import { DocumentUtil } from '../../../utils/document.js';
import { sleep } from '../../../utils/sleep.js';

function Popups() {
  const themeUtil = ThemeUtil();
  const hapticsUtil = HapticsUtil();
  const documentUtil = DocumentUtil();

  document.getElementById('error-msg-0').addEventListener('click', hideError);
  document.getElementById('error-msg-1').addEventListener('click', hideError);
  document
    .getElementById('notification-msg-0')
    .addEventListener('click', hideNotification);
  document
    .getElementById('notification-msg-1')
    .addEventListener('click', hideNotification);
  document
    .getElementById('global-blur')
    .addEventListener('click', hideConfirmationBox);
  document.getElementById('global-blur').addEventListener('click', hideInfoBox);
  document
    .getElementById('global-blur')
    .addEventListener('click', hideInputBox);

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
      document
        .getElementById(`notification-msg-${notificationMsgIndex}`)
        .classList.contains('active')
    )
      return;
    document
      .getElementById(`notification-msg-${notificationMsgIndex}`)
      .classList.add('active');
    document.getElementById(
      `notification-msg-${notificationMsgIndex}`
    ).innerText = message;
  }

  function hideNotification() {
    document
      .getElementById(`notification-msg-${notificationMsgIndex}`)
      .classList.remove('active');
    const [textDiv] = document.getElementById(
      `error-msg-${notificationMsgIndex}`
    ).children;
    textDiv.innerText = '';
  }

  function showError(message) {
    hideError();
    errorMsgIndex = +!errorMsgIndex;
    if (
      document
        .getElementById(`error-msg-${errorMsgIndex}`)
        .classList.contains('active')
    )
      return;
    const [textDiv] = document.getElementById(
      `error-msg-${errorMsgIndex}`
    ).children;
    document
      .getElementById(`error-msg-${errorMsgIndex}`)
      .classList.add('active');
    textDiv.innerText = message;
  }

  function hideError() {
    document
      .getElementById(`error-msg-${errorMsgIndex}`)
      .classList.remove('active');
    const [textDiv] = document.getElementById(
      `error-msg-${errorMsgIndex}`
    ).children;
    textDiv.innerText = '';
  }

  function showConfirmationBox({ title, text, onConfirm }) {
    document.getElementById('global-confirm').children[0].innerText =
      title || 'Default';
    document.getElementById('global-confirm').children[1].innerText =
      text || 'Some text here';
    document
      .getElementById('global-confirm')
      .children[2].children[0].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
    document
      .getElementById('global-confirm')
      .children[2].children[1].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
    document
      .getElementById('global-confirm')
      .children[2].children[0].addEventListener('click', hideConfirmationBox);
    document
      .getElementById('global-confirm')
      .children[2].children[1].addEventListener('click', () => {
        hideConfirmationBox();
        onConfirm();
      });
    document.addEventListener('backbutton', hideConfirmationBox);
    document.getElementById('global-confirm').classList.add('active');
    document.getElementById('global-blur').classList.add('active');
    darkenUi();
  }

  function showInfoBox({ title, content }) {
    document.getElementById('global-info').children[0].children[0].innerText =
      title || 'Default';
    document.getElementById('global-info').children[1].innerHTML = content;
    document
      .getElementById('global-info')
      .children[0].children[1].addEventListener('click', hideInfoBox);
    document
      .getElementById('global-info')
      .children[0].children[1].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
    document.addEventListener('backbutton', hideInfoBox);
    document.getElementById('global-info').classList.add('active');
    document.getElementById('global-blur').classList.add('active');
    darkenUi();
  }

  async function showInputBox({ title, placeholder, callback, focus }) {
    document.getElementById('global-input-prompt').children[0].innerText =
      title || 'Default';
    document.getElementById('global-input-prompt').children[1].innerText =
      placeholder || '';
    document
      .getElementById('global-input-prompt')
      .children[2].children[0].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
    document
      .getElementById('global-input-prompt')
      .children[2].children[1].addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
    document
      .getElementById('global-input-prompt')
      .children[2].children[0].addEventListener('click', hideInputBox);
    document
      .getElementById('global-input-prompt')
      .children[2].children[1].addEventListener('click', () => {
        const value = document.getElementById('global-input-prompt').children[1]
          .innerText;
        hideInputBox();
        callback(value);
      });
    document.getElementById('global-input-prompt').classList.add('active');
    document.getElementById('global-blur').classList.add('active');
    document.addEventListener('backbutton', hideInputBox);
    darkenUi();
    if (focus) {
      await sleep(100);
      const inputArea = document.getElementById('global-input-prompt-textarea');
      inputArea.focus();
      const range = document.createRange();
      const selection = document.getSelection();
      range.setStart(
        inputArea.childNodes[inputArea.childNodes.length - 1],
        inputArea.childNodes[inputArea.childNodes.length - 1].length
      );
      selection.removeAllRanges();
      selection.addRange(range);
    }
  }

  function hideConfirmationBox() {
    document.getElementById('global-confirm').classList.remove('active');
    document.getElementById('global-blur').classList.remove('active');
    documentUtil.removeAllListeners(document.getElementById('global-confirm'));
    document.removeEventListener('backbutton', hideConfirmationBox);
    lightenUi();
  }

  function hideInfoBox() {
    document.getElementById('global-info').classList.remove('active');
    document.getElementById('global-blur').classList.remove('active');
    documentUtil.removeAllListeners(document.getElementById('global-info'));
    document.removeEventListener('backbutton', hideInfoBox);
    lightenUi();
  }

  function hideInputBox() {
    document.getElementById('global-input-prompt').classList.remove('active');
    document.getElementById('global-blur').classList.remove('active');
    documentUtil.removeAllListeners(
      document.getElementById('global-input-prompt')
    );
    document.removeEventListener('backbutton', hideInputBox);
    lightenUi();
  }

  function darkenUi() {
    themeUtil.updateBarsByElementColor(
      document.getElementById('navbar-top'),
      '--surface-container',
      true
    );
  }

  function lightenUi() {
    themeUtil.updateBarsByElementColor(
      document.getElementById('navbar-top'),
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
    showNotification,
    showInputBox,
    hideInputBox
  };
}

export { Popups };
