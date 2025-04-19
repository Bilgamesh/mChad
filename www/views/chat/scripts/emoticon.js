import { DocumentUtil } from '../../../utils/document.js';
import { HapticsUtil } from '../../../utils/haptics.js';

function Emoticon({ el, pictureUrl, code, hide }) {
  const hapticsUtil = HapticsUtil();
  const documentUtil = DocumentUtil();
  const html = /* HTML */ `<img
    class="emoticon"
    src="${pictureUrl}"
    value="${code}"
    hide="false"
  />`;

  function appendElement() {
    const emoticonElement = documentUtil.createElementFromHTML(html);
    addListeners(emoticonElement);
    emoticonElement.setAttribute('hasListener', 'true');
    if (hide) emoticonElement.setAttribute('hide', `${hide}`);
    el.appendChild(emoticonElement);
  }

  function addListeners(el) {
    el.addEventListener('click', addToText);
    el.addEventListener('click', hapticsUtil.tapDefault);
  }

  function getHtml() {
    return html;
  }

  function addToText() {
    let text = document.getElementById('input-box').value.trim();
    text += ' ' + this.getAttribute('value');
    text = text.trim();
    document.getElementById('input-box').value = text + ' ';
    document.getElementById('input-box').focus();
  }

  return { getHtml, appendElement, addListeners };
}

export { Emoticon };
