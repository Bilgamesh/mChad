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
    const dateTime = moment(new Date(time * 1000)).format('LLL');
    const html = /* HTML */ `
      <div
        class="bubble ${side}"
        id="${id}"
        time="${time}"
        user_name="${user.name}"
        user_id="${user.id}"
        message="${encodeQuotes(message.text)}"
        enlarged="false"
        style="opacity: 1;"
      >
        ${documentUtil.fixMessageLinks(baseUrl, message.html)}
      </div>
      <div class="label label-${side}" style="opacity: 1;">
        ${user.name} • ${dateTime}
      </div>
      <div
        class="avatar av-${side}"
        style="opacity: 1; background-image: url(${avatar.src.replace(
          './',
          `${baseUrl}/`
        )})"
      ></div>
    `;

    function createBubble() {
      const bubble = document.createElement('div');
      const className = `bubble ${side}`;
      bubble.setAttribute('class', className);
      bubble.setAttribute('id', id);
      bubble.setAttribute('time', time);
      bubble.setAttribute('user_name', user.name);
      bubble.setAttribute('user_id', user.id);
      bubble.setAttribute('message', message.text);
      bubble.innerHTML = documentUtil.fixMessageLinks(baseUrl, message.html);
      return bubble;
    }

    function createAvatar() {
      const av = document.createElement('div');
      const avClassName = `avatar av-${side}`;
      av.setAttribute('class', avClassName);
      av.setAttribute(
        'style',
        `opacity: 1; background-image: url(${avatar.src.replace(
          './',
          `${baseUrl}/`
        )})`
      );
      return av;
    }

    function createLabel() {
      const label = document.createElement('div');
      const labelClassName = `label label-${side}`;
      label.setAttribute('class', labelClassName);
      moment.locale(languages.getCurrentLanguage());
      const dateTime = moment(new Date(time * 1000)).format('LLL');
      label.innerText = `${user.name} • ${dateTime}`;
      return label;
    }

    function insertElement({ before, fadeIn }) {
      const bubble = createBubble();
      const av = createAvatar();
      const label = createLabel();

      if (fadeIn > 0) {
        bubble.style.opacity = 0;
        av.style.opacity = 0;
        label.style.opacity = 0;
      }

      el.insertBefore(av, before);
      el.insertBefore(label, av);
      el.insertBefore(bubble, label);

      if (fadeIn > 0) {
        animationsUtil.fadeIn(bubble, fadeIn || 200);
        animationsUtil.fadeIn(av, fadeIn || 200);
        animationsUtil.fadeIn(label, fadeIn || 200);
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
