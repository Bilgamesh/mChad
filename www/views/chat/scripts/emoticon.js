(function () {
  function Emoticon({
    el,
    pictureUrl,
    code,
    documentUtil,
    hide,
    hapticsUtil
  }) {
    const html = /* HTML */ `<img
      class="emoticon"
      src="${pictureUrl}"
      value="${code}"
      hide="false"
    />`;

    function appendElement() {
      const emoticonElement = documentUtil.createHtmlElement({
        element: 'img',
        className: 'emoticon',
        src: pictureUrl,
        value: code,
        hapticFeedback: true,
        hasListener: 'true'
      });
      addListeners(emoticonElement);
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
      let text = $('#input-box').value.trim();
      text += ' ' + this.getAttribute('value');
      text = text.trim();
      $('#input-box').value = text + ' ';
      $('#input-box').focus();
    }

    return { getHtml, appendElement, addListeners };
  }
  window.modules = window.modules || {};
  window.modules.Emoticon = Emoticon;
})();
