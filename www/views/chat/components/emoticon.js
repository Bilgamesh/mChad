(function () {
  function Emoticon({
    el,
    pictureUrl,
    code,
    onClick,
    documentUtil,
    hide,
    hapticFeedback
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
        hapticFeedback
      });
      if (onClick) emoticonElement.addEventListener('click', onClick);
      if (hide) emoticonElement.setAttribute('hide', `${hide}`);
      el.appendChild(emoticonElement);
    }

    function getHtml() {
      return html;
    }

    return { getHtml, appendElement };
  }
  window.modules = window.modules || {};
  window.modules.Emoticon = Emoticon;
})();
