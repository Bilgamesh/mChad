import { AndroidUtil } from '../../../utils/android.js';
import { Emoticon } from './emoticon.js';

function EmoticonPanel({ emoticons }) {
  const androidUtil = AndroidUtil();

  let html = '';
  let keyboardOffListenerId;

  function init() {
    html = /* HTML */ `<div
      id="emoticon-panel"
      class="row scroll page bottom"
      hide="true"
    >
      ${getEmoticonsHtml()}
    </div>`;
  }

  function getEmoticonsHtml() {
    let emoticonsHtml = '';
    for (const { pictureUrl, code } of emoticons)
      emoticonsHtml += Emoticon({ pictureUrl, code }).getHtml();
    return emoticonsHtml;
  }

  function registerListeners() {
    document.addEventListener('click', hideEmoticonsOnBlur);
    keyboardOffListenerId = androidUtil.addKeyboardOffListener(hideEmoticons);
    document
      .getElementById('emoji-icon')
      .addEventListener('click', toggleEmoticons);
    for (const emoticonElement of document.getElementsByClassName('emoticon'))
      if (emoticonElement.getAttribute('hasListener') !== 'true')
        Emoticon({}).addListeners(emoticonElement);
  }

  function getHtml() {
    return html;
  }

  function update({ emoticons }) {
    // Don't modify emoticon panel if there are already some emoticons there
    // and user is using them
    if (
      document.getElementsByClassName('emoticon').length &&
      document.getElementById('emoticon-panel').classList.contains('active')
    )
      return;
    if (emoticons.length > 0)
      document.getElementById('emoticon-panel').innerHTML = '';
    for (const { pictureUrl, code } of emoticons)
      Emoticon({
        el: document.getElementById('emoticon-panel'),
        pictureUrl,
        code,
        hide: true
      }).appendElement();
  }

  function toggleEmoticons() {
    if (document.getElementById('emoticon-panel').classList.contains('active'))
      hideEmoticons();
    else showEmoticons();
    document.getElementById('input-box').focus();
  }

  function showEmoticons() {
    document.getElementById('emoticon-panel').classList.add('active');
    document.getElementById('emoticon-panel').setAttribute('hide', 'false');
    for (const emoticon of document.getElementsByClassName('emoticon'))
      emoticon.setAttribute('hide', 'false');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('lifted', 'true');
  }

  function hideEmoticons() {
    document.getElementById('emoticon-panel').classList.remove('active');
    document.getElementById('emoticon-panel').setAttribute('hide', 'true');
    for (const emoticon of document.getElementsByClassName('emoticon'))
      emoticon.setAttribute('hide', 'true');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('lifted', 'false');
  }

  function hideEmoticonsOnBlur(event) {
    try {
      if (
        event.target === document.getElementById('emoji-icon') ||
        event.target === document.getElementById('input-box')
      )
        return;
      hideEmoticons();
    } catch (err) {}
  }

  function onDestroy() {
    document.removeEventListener('click', hideEmoticonsOnBlur);
    androidUtil.removeKeyboardOffListener(keyboardOffListenerId);
  }

  return { init, getHtml, update, registerListeners, onDestroy };
}

export { EmoticonPanel };
