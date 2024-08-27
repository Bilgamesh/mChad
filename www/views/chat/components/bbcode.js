(function () {
  function BBCode({
    el,
    bbtag,
    documentUtil,
    hapticsUtil,
    hide,
    clipboardUtil
  }) {
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
      const bbcodeElement = documentUtil.createHtmlElement({
        element: 'div',
        className: 'chip fill bbcode',
        hapticFeedback: true,
        hasListener: 'true',
        start: bbtag.start,
        end: bbtag.end,
        innerHTML: bbtag.icon ? `<i>${bbtag.icon}</i>` : bbtag.name
      });
      addListeners(bbcodeElement);
      if (hide) bbcodeElement.setAttribute('hide', `${hide}`);
      el.appendChild(bbcodeElement);
    }

    function addListeners(el) {
      el.addEventListener('click', onBBcodeTap);
    }

    function silentTrimInputBox() {
      const selectionStart = $('#input-box').selectionStart;
      const selectionEnd = $('#input-box').selectionEnd;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').selectionStart = selectionStart;
      $('#input-box').selectionEnd = selectionEnd;
    }

    async function onBBcodeTap() {
      hapticsUtil.tapDefault;
      if (
        isDoubleTap(this) &&
        isCursorInsideEmptyBBtag(this) &&
        (await hasClipboard())
      )
        await addClipboardToText();
      else addBBCodeToText(this);
    }

    function isCursorInsideEmptyBBtag(scope) {
      const selectionStart = $('#input-box').selectionStart;
      const selectionEnd = $('#input-box').selectionEnd;
      if (selectionStart !== selectionEnd) return false;
      const bbCodeStart = scope.getAttribute('start');
      const bbCodeEnd = scope.getAttribute('end');
      const text = $('#input-box').value;
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
        const selectionStart = $('#input-box').selectionStart;
        let text = $('#input-box').value;
        text =
          text.slice(0, selectionStart) +
          clipboard +
          text.slice(selectionStart);
        $('#input-box').value = text;
        $('#input-box').focus();
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
      const selectionStart = $('#input-box').selectionStart;
      const selectionEnd = $('#input-box').selectionEnd;
      let text = $('#input-box').value;
      text =
        text.slice(0, selectionStart) +
        bbCodeStart +
        text.slice(selectionStart, selectionEnd) +
        bbCodeEnd +
        text.slice(selectionEnd);
      text = text.trim();
      $('#input-box').value = text + ' ';
      $('#input-box').focus();
      $('#input-box').selectionStart = selectionStart + bbCodeStart.length;
      $('#input-box').selectionEnd = selectionEnd + bbCodeStart.length;
    }

    return { getHtml, addListeners, appendElement };
  }
  window.modules = window.modules || {};
  window.modules.BBCode = BBCode;
})();
