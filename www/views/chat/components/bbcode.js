(function () {
  function BBCode({ el, bbtag, documentUtil, hapticsUtil, hide }) {
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
      el.addEventListener('click', addToText);
      el.addEventListener('click', hapticsUtil.tapDefault);
    }

    function silentTrimInputBox() {
      const selectionStart = $('#input-box').selectionStart;
      const selectionEnd = $('#input-box').selectionEnd;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').selectionStart = selectionStart;
      $('#input-box').selectionEnd = selectionEnd;
    }

    function addToText() {
      silentTrimInputBox();
      const bbCodeStart = this.getAttribute('start');
      const bbCodeEnd = this.getAttribute('end');
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
