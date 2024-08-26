(function () {
  function EmoticonPanel({ emoticons, Emoticon, documentUtil, hapticsUtil }) {
    let html = '';

    function init() {
      html = /* HTML */`<div id="emoticon-panel" class="row scroll page bottom" hide="true">${getEmoticonsHtml()}</div>`;
    }

    function getEmoticonsHtml() {
      let emoticonsHtml = '';
      for (const { pictureUrl, code } of emoticons)
        emoticonsHtml += Emoticon({ pictureUrl, code }).getHtml();
      return emoticonsHtml;
    }

    function registerListeners() {
      document.addEventListener('click', hideEmoticonsOnBlur);
      $('#emoji-icon').addEventListener('click', toggleEmoticons);
      for (const emoticonElement of $('.emoticon'))
        if (emoticonElement.getAttribute('hasListener') !== 'true')
          Emoticon({ hapticsUtil }).addListeners(emoticonElement);
    }

    function getHtml() {
      return html;
    }

    function update({ emoticons }) {
      // Don't modify emoticon panel if there are already some emoticons there
      // and user is using them
      if (
        $('.emoticon').length &&
        $('#emoticon-panel').classList.contains('active')
      )
        return;
      if (emoticons.length > 0) $('#emoticon-panel').innerHTML = '';
      for (const { pictureUrl, code } of emoticons)
        Emoticon({
          el: $('#emoticon-panel'),
          pictureUrl,
          code,
          documentUtil,
          hide: true,
          hapticsUtil
        }).appendElement();
    }

    function toggleEmoticons() {
      if ($('#emoticon-panel').classList.contains('active')) hideEmoticons();
      else showEmoticons();
      $('#input-box').focus();
    }

    function showEmoticons() {
      $('#emoticon-panel').classList.add('active');
      $('#emoticon-panel').setAttribute('hide', 'false');
      for (const emoticon of $('.emoticon'))
        emoticon.setAttribute('hide', 'false');
      $('#scroll-to-bottom-circle').setAttribute('lifted', 'true');
    }

    function hideEmoticons() {
      $('#emoticon-panel').classList.remove('active');
      $('#emoticon-panel').setAttribute('hide', 'true');
      for (const emoticon of $('.emoticon'))
        emoticon.setAttribute('hide', 'true');
      $('#scroll-to-bottom-circle').setAttribute('lifted', 'false');
    }

    function hideEmoticonsOnBlur(event) {
      try {
        if (
          event.target === $('#emoji-icon') ||
          event.target === $('#input-box')
        )
          return;
        hideEmoticons();
      } catch (err) {}
    }

    function onDestroy() {
      document.removeEventListener('click', hideEmoticonsOnBlur);
    }

    return { init, getHtml, update, registerListeners, onDestroy };
  }
  window.modules = window.modules || {};
  window.modules.EmoticonPanel = EmoticonPanel;
})();
