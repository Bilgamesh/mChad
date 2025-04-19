import { ClipboardUtil } from '../../../utils/clipboard.js';
import { DocumentUtil } from '../../../utils/document.js';
import { HapticsUtil } from '../../../utils/haptics.js';

function BBCode({ el, bbtag, hide }) {
  const documentUtil = DocumentUtil();
  const hapticsUtil = HapticsUtil();
  const clipboardUtil = ClipboardUtil();

  const MAX_DOUBLE_TAP_TIME_DIFF_MS = 1000;
  let lastTouchTime = new Date(0);
  let lastBBtag = '';
  const html = /* HTML */ `<div
    class="chip fill bbcode"
    start="${bbtag.start}"
    end="${bbtag.end}"
    hide="false"
  >
    ${bbtag.icon ? `<i>${bbtag.icon}</i>` : bbtag.name}
  </div>`;

  function getHtml() {
    return html;
  }

  function appendElement() {
    const bbcodeElement = documentUtil.createElementFromHTML(html);
    bbcodeElement.setAttribute('hasListener', 'true');
    addListeners(bbcodeElement);
    if (hide) bbcodeElement.setAttribute('hide', `${hide}`);
    el.appendChild(bbcodeElement);
  }

  function addListeners(el) {
    el.addEventListener('click', onBBcodeTap);
  }

  function silentTrimInputBox() {
    const selectionStart = document.getElementById('input-box').selectionStart;
    const selectionEnd = document.getElementById('input-box').selectionEnd;
    document.getElementById('input-box').value =
      document.getElementById('input-box').value.trim() + ' ';
    document.getElementById('input-box').selectionStart = selectionStart;
    document.getElementById('input-box').selectionEnd = selectionEnd;
  }

  async function onBBcodeTap() {
    hapticsUtil.tapDefault();
    if (
      isDoubleTap(this) &&
      isCursorInsideEmptyBBtag(this) &&
      (await hasClipboard())
    )
      await addClipboardToText();
    else addBBCodeToText(this);
  }

  function isCursorInsideEmptyBBtag(scope) {
    const selectionStart = document.getElementById('input-box').selectionStart;
    const selectionEnd = document.getElementById('input-box').selectionEnd;
    if (selectionStart !== selectionEnd) return false;
    const bbCodeStart = scope.getAttribute('start');
    const bbCodeEnd = scope.getAttribute('end');
    const text = document.getElementById('input-box').value;
    const part1 = text.slice(0, selectionStart);
    const part2 = text.slice(selectionStart);
    return part1.endsWith(bbCodeStart) && part2.startsWith(bbCodeEnd);
  }

  function isDoubleTap(scope) {
    const bbCodeStart = scope.getAttribute('start');
    if (
      new Date() - lastTouchTime > MAX_DOUBLE_TAP_TIME_DIFF_MS ||
      bbCodeStart !== lastBBtag
    ) {
      lastBBtag = bbCodeStart;
      lastTouchTime = new Date();
      return false;
    } else {
      lastBBtag = bbCodeStart;
      lastTouchTime = new Date();
      return true;
    }
  }

  async function hasClipboard() {
    const clipboard = await clipboardUtil.paste();
    return !!clipboard;
  }

  async function addClipboardToText() {
    try {
      const clipboard = await clipboardUtil.paste();
      const selectionStart =
        document.getElementById('input-box').selectionStart;
      let text = document.getElementById('input-box').value;
      text =
        text.slice(0, selectionStart) + clipboard + text.slice(selectionStart);
      document.getElementById('input-box').value = text;
      document.getElementById('input-box').focus();
    } catch (err) {
      console.log(
        `[${new Date().toLocaleString()}][BBCODE] Failed to add clipboard to text`
      );
      return;
    }
  }

  function addBBCodeToText(scope) {
    silentTrimInputBox();
    const bbCodeStart = scope.getAttribute('start');
    const bbCodeEnd = scope.getAttribute('end');
    const selectionStart = document.getElementById('input-box').selectionStart;
    const selectionEnd = document.getElementById('input-box').selectionEnd;
    let text = document.getElementById('input-box').value;
    text =
      text.slice(0, selectionStart) +
      bbCodeStart +
      text.slice(selectionStart, selectionEnd) +
      bbCodeEnd +
      text.slice(selectionEnd);
    text = text.trim();
    document.getElementById('input-box').value = text + ' ';
    document.getElementById('input-box').focus();
    document.getElementById('input-box').selectionStart =
      selectionStart + bbCodeStart.length;
    document.getElementById('input-box').selectionEnd =
      selectionEnd + bbCodeStart.length;
  }

  return { getHtml, addListeners, appendElement };
}
export { BBCode };
