(function () {
  function Message({
    el,
    side,
    id,
    time,
    user,
    message,
    baseUrl,
    avatar,
    languages,
    animationsUtil,
    documentUtil,
    sleep
  }) {
    moment.locale(languages.getCurrentLanguage());
    const dateTime = moment(new Date(time * 1000)).format('LLL');
    const html = /* HTML */ `
      <div
        id="${id}"
        class="bubble ${side}"
        time="${time}"
        user_name="${user.name}"
        user_id="${user.id}"
        message="${encodeQuotes(message.text)}"
        enlarged="false"
        style=""
      >
        ${documentUtil.fixMessageLinks(baseUrl, message.html)}
      </div>
      <div id="label-${id}" class="label label-${side}" style="">
        ${user.name} • ${dateTime}
      </div>
      <div
        id="av-${id}"
        class="avatar av-${side}"
        style="background-image: url(${avatar.src.replace(
          './',
          `${baseUrl}/`
        )})"
      ></div>
    `;

    function insertElement({ before, fadeIn }) {
      const template = document.createElement('template');
      template.innerHTML = getHtml();

      for (let i = template.content.children.length - 1; i >= 0; i--) {
        const node = template.content.children[i];
        node.style.opacity = fadeIn > 0 ? 0 : 1;
        el.insertBefore(node, before);
        before = node;
      }

      if (fadeIn > 0) {
        animationsUtil.fadeIn($('#' + id), fadeIn || 200);
        animationsUtil.fadeIn($('#av-' + id), fadeIn || 200);
        animationsUtil.fadeIn($('#label-' + id), fadeIn || 200);
      }
    }

    function encodeQuotes(text) {
      return text.split('"').join('&quot;');
    }

    function getHtml() {
      return html;
    }

    async function update(newMessage) {
      message = newMessage;
      const oldMessage = $(`#${id}`);
      oldMessage.classList.remove('blink');
      await sleep(50);
      oldMessage.classList.add('blink');
      await sleep(500);
      oldMessage.innerHTML = documentUtil.fixMessageLinks(
        baseUrl,
        newMessage.message.html
      );
      oldMessage.setAttribute('id', newMessage.id);
      oldMessage.setAttribute('time', newMessage.time);
      oldMessage.setAttribute('message', newMessage.message.text);
      oldMessage.classList.remove('blink');
    }

    function remove(silent) {
      const message = $(`#${id}`);
      const label = message.nextElementSibling;
      const avatar = label.nextElementSibling;
      if (silent) {
        message.parentNode.removeChild(message);
        label.parentNode.removeChild(label);
        avatar.parentNode.removeChild(avatar);
      } else {
        animationsUtil.removeFadeOut(message, 200);
        animationsUtil.removeFadeOut(label, 200);
        animationsUtil.removeFadeOut(avatar, 200);
      }
    }

    return { id, getHtml, insertElement, update, remove };
  }
  window.modules = window.modules || {};
  window.modules.Message = Message;
})();
