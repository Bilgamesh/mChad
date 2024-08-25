(function () {
  function ChatUi({
    el,
    loggedInUserId,
    forumName,
    baseUrl,
    currentForumIndex,
    documentUtil,
    hapticsUtil,
    animationsUtil,
    androidUtil,
    languages,
    sleep,
    navbar,
    Message,
    Emoticon,
    getLikeMessage
  }) {
    let lastSelected;
    const messageSubmitListeners = [];
    const messageBubbles = [];

    $('#navbar-top-title').innerText = forumName || baseUrl;

    async function displayPage(messages, emoticons) {
      /* Emptying the page just before re-rendering
      and giving browser an overhead via dummy timeout
      makes BeerCSS transition animations much smoother */
      while (el.firstChild) el.removeChild(el.firstChild);
      await sleep(0);

      el.innerHTML = /* HTML */ `
        <center
          id="loading-circle"
          class="loading-circle"
          hide="${!!messages.length}"
        >
          <progress class="circle large"></progress>
        </center>

        <nav id="tools-panel" class="right-align" hide="true">
          <i id="reply-button" class="tool-item unhoverable">alternate_email</i>
          <i id="quote-button" class="tool-item unhoverable">format_quote</i>
          <i id="like-button" class="tool-item unhoverable">thumb_up</i>
          <i id="copy-button" class="tool-item unhoverable">content_copy</i>
        </nav>

        <div id="chat" class="chat page active">
          <br /><br />
          ${buildMessagesHtml(messages)}
          <div id="chat-beginning"></div>
          <br /><br /><br /><br /><br /><br /><br />
        </div>

        <button
          id="scroll-to-bottom-circle"
          class="circle medium fill"
          hide="true"
        >
          <i>south</i>
        </button>

        <div id="emoticon-panel" class="row scroll page bottom" hide="true">
          ${buildEmoticonsHtml(emoticons)}
        </div>

        <div id="text-panel" class="page bottom text-panel active">
          <form id="chat-form">
            <div id="text-field" class="field label fill small round">
              <input id="input-box" type="text" class="text-field" />
              <label>${await languages.getTranslation('TYPE_SOMETHING')}</label>
              <i id="emoji-icon" class="emoji-icon">emoticon</i>
            </div>
          </form>
        </div>
      `;

      addBubbleContentListeners();
      scrollToBottom('instant');
    }

    function init() {
      registerHaptics();
      registerButtons();
    }

    function registerHaptics() {
      $('#emoji-icon').addEventListener('click', hapticsUtil.tapDefault);
      $('#scroll-to-bottom-circle').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      for (const emoticon of $('.emoticon'))
        emoticon.addEventListener('click', hapticsUtil.tapDefault);
      for (const toolItem of $('.tool-item'))
        toolItem.addEventListener('click', hapticsUtil.tapDefault);
    }

    function registerButtons() {
      document.addEventListener('click', hideEmoticonsOnBlur);
      $('#emoji-icon').addEventListener('click', toggleEmoticons);

      $('#scroll-to-bottom-circle').addEventListener(
        'click',
        animationsUtil.getClickEffect($('#scroll-to-bottom-circle'))
      );
      $('#scroll-to-bottom-circle').addEventListener('click', () =>
        scrollToBottom('smooth')
      );
      $('#chat').addEventListener('scroll', toggleScrollButtonVisibility);
      $('#chat-form').addEventListener('submit', submitMessage);
      for (const emoticon of $('.emoticon')) {
        emoticon.addEventListener('click', addEmoticonToText);
      }
      $('#reply-button').addEventListener('click', reply);
      $('#quote-button').addEventListener('click', quote);
      $('#like-button').addEventListener('click', like);
      $('#copy-button').addEventListener('click', copy);
    }

    function reply() {
      const userId = lastSelected.getAttribute('user_id');
      const userName = lastSelected.getAttribute('user_name');
      const replyMessage = `@[url=${baseUrl}/memberlist.php?mode=viewprofile&u=${userId}][b]${userName}[/b][/url]`;
      $('#input-box').value = $('#input-box').value.trim() + ' ' + replyMessage;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').focus();
    }

    function quote() {
      const userId = lastSelected.getAttribute('user_id');
      const userName = lastSelected.getAttribute('user_name');
      const postId = lastSelected.getAttribute('id');
      const postTime = lastSelected.getAttribute('time');
      const message = lastSelected.getAttribute('message');
      const quoteMessage = `[quote="${userName}" post_id=${postId} time=${postTime} user_id=${userId}] ${message} [/quote]`;
      $('#input-box').value = $('#input-box').value.trim() + ' ' + quoteMessage;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').focus();
    }

    function like() {
      const userId = lastSelected.getAttribute('user_id');
      const userName = lastSelected.getAttribute('user_name');
      const postId = lastSelected.getAttribute('id');
      const postTime = lastSelected.getAttribute('time');
      const message = lastSelected.getAttribute('message');
      const likeResponse = `[i]${getLikeMessage()}[/i][quote="${userName}" post_id=${postId} time=${postTime} user_id=${userId}] ${message} [/quote]`;
      $('#input-box').value = $('#input-box').value.trim() + ' ' + likeResponse;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').focus();
    }

    function copy() {
      const message = lastSelected.getAttribute('message');
      navigator.clipboard.writeText(message);
    }

    function addMessages({ messages, scrollType, forumIndex }) {
      messages = messages.filter((m) => !isAlreadyAdded(m));
      if (currentForumIndex != forumIndex) return;
      // if (isFirstBatch()) return addMessagesFirstBatch(messages);
      for (const { id, time, user, message, avatar } of messages) {
        const messageBubble = Message({
          el: $('#chat'),
          side: user.id === loggedInUserId ? 'right' : 'left',
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
        });
        messageBubble.insertElement({
          before: $('#chat-beginning'),
          fadeIn: 200
        });
        messageBubbles.push(messageBubble);
      }
      addBubbleContentListeners();
      hideLoadingCircle();
      if (messages.length > 0) scrollToBottom(scrollType || 'smooth');
    }

    function isAlreadyAdded({ id }) {
      const addedMessages = $('.bubble');
      for (const message of addedMessages) if (message.id == id) return true;
      return false;
    }

    function buildMessagesHtml(messages) {
      let result = '';
      for (const { id, time, user, message, avatar } of messages) {
        moment.locale(languages.getCurrentLanguage());
        const side = user.id === loggedInUserId ? 'right' : 'left';
        const messageBubble = Message({
          side,
          id,
          time,
          user,
          message,
          baseUrl,
          avatar,
          animationsUtil,
          documentUtil,
          sleep
        });
        result += messageBubble.getHtml();
        messageBubbles.push(messageBubble);
      }
      addBubbleContentListeners();
      return result;
    }

    function buildEmoticonsHtml(emoticons) {
      let result = '';
      for (const { pictureUrl, code } of emoticons)
        result += Emoticon({ pictureUrl, code }).getHtml();
      return result;
    }

    function addEmoticonsToUi({ emoticons, forumIndex }) {
      if (currentForumIndex != forumIndex) return;
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
          onClick: addEmoticonToText,
          documentUtil,
          hide: true,
          hapticFeedback: true
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

    function addEmoticonToText() {
      let text = $('#input-box').value.trim();
      text += ' ' + this.getAttribute('value');
      text = text.trim();
      $('#input-box').value = text + ' ';
      $('#input-box').focus();
    }

    function deleteMessage({ id, forumIndex, silent }) {
      if (currentForumIndex != forumIndex) return;
      const index = messageBubbles.findIndex((bubble) => bubble.id == id);
      if (index !== -1) return;
      messageBubbles[index].remove(silent);
      messageBubbles.splice(index, 1);
    }

    async function editMessage({ message, forumIndex }) {
      if (currentForumIndex != forumIndex) return;
      const messageBubble = messageBubbles.find(
        (bubble) => bubble.id == message.id
      );
      if (!messageBubbles) return;
      await messageBubble.update(message);
      addBubbleContentListeners();
    }

    function addBubbleContentListeners() {
      addImageListeners();
      addLinkListeners();
    }

    function addImageListeners() {
      const images = document.querySelectorAll('a.clickable-image');
      for (const image of images)
        if (image.getAttribute('listener') != 1) {
          image.addEventListener('click', () =>
            androidUtil.openInFullScreenBrowser(image.getAttribute('image-url'))
          );
          image.setAttribute('listener', 1);
        }
    }

    function addLinkListeners() {
      const links = document.querySelectorAll('a.clickable-link');
      for (const link of links)
        if (link.getAttribute('listener') != 1) {
          link.addEventListener('click', () =>
            androidUtil.openInBrowser(
              link.getAttribute('target-url'),
              '_system'
            )
          );
          link.setAttribute('listener', 1);
        }
    }

    function submitMessage(event) {
      event.preventDefault();
      const text = $('#text-field').children[0].value || '';
      $('#text-field').children[0].value = '';
      androidUtil.hideKeyboard($('#text-field'));
      document.activeElement.blur();
      if (!text.trim()) return;
      for (const listener of messageSubmitListeners) {
        listener.listen(text);
      }
    }

    function toggleScrollButtonVisibility() {
      if (
        $('#chat').scrollHeight - $('#chat').scrollTop >
        $('#chat').clientHeight * 2
      )
        $('#scroll-to-bottom-circle').setAttribute('hide', 'false');
      else $('#scroll-to-bottom-circle').setAttribute('hide', 'true');
    }

    function showNavbar() {
      navbar.show();
      $('#text-panel').setAttribute('expanded', 'false');
      $('#emoticon-panel').setAttribute('expanded', 'false');
      $('#main-page').setAttribute('expanded', 'false');
      $('#scroll-to-bottom-circle').setAttribute('expanded', 'false');
    }

    function hideNavbar() {
      navbar.hide();
      $('#text-panel').setAttribute('expanded', 'true');
      $('#emoticon-panel').setAttribute('expanded', 'true');
      $('#main-page').setAttribute('expanded', 'true');
      $('#scroll-to-bottom-circle').setAttribute('expanded', 'true');
    }

    async function scrollToBottom(behavior) {
      if (behavior === 'instant') {
        do {
          await sleep(0); // gives browser overhead for rendering when height of the chat is not rendered yet
          $('#chat').scrollTop = $('#chat').scrollHeight;
        } while ($('#chat').scrollTop === 0);
        return;
      }
      $('#chat').scrollTo({
        top: $('#chat').scrollHeight,
        behavior: behavior || 'instant'
      });
    }

    function showLoadingCircle() {
      $('#loading-circle').setAttribute('hide', 'false');
    }

    function hideLoadingCircle() {
      $('#loading-circle').setAttribute('hide', 'true');
    }

    function findBubbleByChild(child) {
      for (const bubble of document.getElementsByClassName('bubble'))
        if (bubble.contains(child)) return bubble;
      return null;
    }

    function startShaking(target) {
      if (target.classList.contains('bubble'))
        target.setAttribute('shaking', 'true');
    }

    function stopShaking(target) {
      if (target.getAttribute('shaking') === 'true') lastSelected = target;
      target.setAttribute('shaking', 'false');
    }

    function stopShakingAllBubbles() {
      for (const element of document.getElementsByClassName('bubble'))
        stopShaking(element);
    }

    function enlarge(target) {
      target.setAttribute('enlarged', 'true');
    }

    function shrink(target) {
      target.setAttribute('enlarged', 'false');
    }

    function shrinkAllBubbles() {
      for (const element of document.getElementsByClassName('bubble'))
        shrink(element);
    }

    function isShaking(target) {
      return target.getAttribute('shaking') === 'true';
    }

    function isAnyBubbleShaking() {
      return !!document.querySelector('[shaking="true"]');
    }

    function showToolbar() {
      $('#tools-panel').setAttribute('hide', 'false');
    }

    function hideToolbar() {
      $('#tools-panel')?.setAttribute('hide', 'true');
    }

    function onDestroy() {
      document.removeEventListener('click', hideEmoticonsOnBlur);
    }

    function addMessageSubmitListener(listen) {
      messageSubmitListeners.push({ listen });
    }

    return {
      init,
      displayPage,
      addMessages,
      buildMessagesHtml,
      addEmoticonsToUi,
      buildEmoticonsHtml,
      deleteMessage,
      editMessage,
      submitMessage,
      showNavbar,
      hideNavbar,
      scrollToBottom,
      showLoadingCircle,
      hideLoadingCircle,
      hideEmoticons,
      findBubbleByChild,
      startShaking,
      stopShaking,
      stopShakingAllBubbles,
      enlarge,
      shrink,
      shrinkAllBubbles,
      isShaking,
      isAnyBubbleShaking,
      showToolbar,
      hideToolbar,
      onDestroy,
      addMessageSubmitListener
    };
  }

  window.modules = window.modules || {};
  window.modules.ChatUi = ChatUi;
})();