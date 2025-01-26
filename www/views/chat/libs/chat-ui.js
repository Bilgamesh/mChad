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
    EmoticonPanel,
    ToolsPanel,
    BBCode,
    BBCodesPanel,
    clipboardUtil,
    config,
    infiniteScroll,
    inMemoryStore,
    forumStorage,
    ScrollUtil
  }) {
    const cache = { lastSelected: null };
    const messageSubmitListeners = [];
    let messageBubbles = [];
    const toolsPanel = ToolsPanel({
      baseUrl,
      chatUiCache: cache,
      inMemoryStore
    });
    let emoticonPanel;
    let bbcodesPanel;
    let scrollUtil;

    $('#navbar-top-title').innerText = forumName || baseUrl;

    async function displayPage(messages, emoticons, bbtags) {
      /* Emptying the page just before re-rendering
      and giving browser an overhead via dummy timeout
      makes BeerCSS transition animations much smoother */
      while (el.firstChild) el.removeChild(el.firstChild);
      await sleep(0);

      messages = messages.slice(messages.length - config.MAX_MESSAGE_AMOUNT);

      emoticonPanel = EmoticonPanel({
        emoticons,
        Emoticon,
        documentUtil,
        hapticsUtil,
        androidUtil
      });
      bbcodesPanel = BBCodesPanel({
        bbtags,
        BBCode,
        documentUtil,
        hapticsUtil,
        androidUtil,
        clipboardUtil
      });

      emoticonPanel.init();
      bbcodesPanel.init();

      el.innerHTML = /* HTML */ `
        <progress id="progress-bar" class="progress-bar" hide="true"></progress>
        <center
          id="loading-circle"
          class="loading-circle"
          hide="${!!messages.length}"
        >
          <progress class="circle large"></progress>
        </center>

        ${toolsPanel.getHtml()}

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

        ${emoticonPanel.getHtml()} ${bbcodesPanel.getHtml()}

        <div id="text-panel" class="page bottom text-panel active">
          <form id="chat-form">
            <div id="text-field" class="field label fill small round">
              <input id="input-box" type="text" class="text-field" />
              <label>${await languages.getTranslation('TYPE_SOMETHING')}</label>
              <i id="bbcodes-panel-icon" class="bbcodes-panel-icon">code</i>
              <i id="emoji-icon" class="emoji-icon">emoticon</i>
            </div>
          </form>
        </div>
      `;

      addBubbleContentListeners();
      scrollToBottom('instant');
    }

    function init() {
      scrollUtil = ScrollUtil($('#chat'));
      registerHaptics();
      registerButtons();
      registerListeners();
      emoticonPanel.registerListeners();
      bbcodesPanel.registerListeners();
      if ($('.bubble').length) infiniteScroll.init(scrollUtil, messageBubbles);
    }

    function registerHaptics() {
      $('#emoji-icon').addEventListener('click', hapticsUtil.tapDefault);
      $('#bbcodes-panel-icon').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      $('#scroll-to-bottom-circle').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      for (const toolItem of $('.tool-item'))
        toolItem.addEventListener('click', hapticsUtil.tapDefault);
    }

    function registerButtons() {
      $('#scroll-to-bottom-circle').addEventListener(
        'click',
        animationsUtil.getClickEffect($('#scroll-to-bottom-circle'))
      );
      $('#scroll-to-bottom-circle').addEventListener(
        'click',
        onScrollToBottomClicked
      );
      $('#chat').addEventListener('scroll', toggleScrollButtonVisibility);
      $('#chat-form').addEventListener('submit', submitMessage);
      toolsPanel.registerListeners();
    }

    function onScrollToBottomClicked() {
      hideToolbar();
      if (isBottomVisible()) scrollToBottom('smooth');
      else rerenderPage();
    }

    function registerListeners() {
      $('#chat').addEventListener('scroll', () => {
        const messages = inMemoryStore.get('messages');
        if (areNewMessagesVisible()) markMessagesAsRead(messages);
        updateBadge();
        if (!isAnyBubbleShaking()) hideToolbar();
      });
    }

    function updateBadge() {
      if (areNewMessagesVisible())
        navbar.displayBadge({
          element: $('#chat-btn'),
          id: 'chat-badge',
          number: 0
        });
    }

    function areNewMessagesVisible({ screenDistance } = {}) {
      return (
        isBottomVisible() &&
        !scrollUtil.isViewportNScreensAwayFromBottom(screenDistance || 2)
      );
    }

    async function rerenderPage() {
      const messages = inMemoryStore.get('messages') || [];
      const emoticons = forumStorage.get('emoticons') || [];
      const bbtags = forumStorage.get('bbtags') || [];
      messageBubbles.length = 0;
      await displayPage(messages, emoticons, bbtags);
      init();
    }

    function addMessages({ messages, scrollType, forumIndex }) {
      if (currentForumIndex != forumIndex) return;
      const isFirstBatch = !$('.bubble').length;
      if (scrollUtil.isViewportNScreensAwayFromBottom(2) && !isFirstBatch)
        return;
      markMessagesAsRead(messages);
      messages = messages.filter((m) => !isAlreadyAdded(m));
      messages = messages.slice(messages.length - config.MAX_MESSAGE_AMOUNT);
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
      if (isFirstBatch) infiniteScroll.init(scrollUtil, messageBubbles);
      if (
        messages.length > 0 &&
        !scrollUtil.isViewportNScreensAwayFromBottom(2)
      ) {
        scrollToBottom(scrollType || 'smooth');
      }
    }

    async function addOldMessages({ messages, forumIndex }) {
      messages = messages.filter((m) => !isAlreadyAdded(m));
      messages = messages.slice(0, config.MAX_MESSAGE_AMOUNT);
      if (currentForumIndex != forumIndex) return;
      if (scrollUtil.isScrolledToTop()) scrollUtil.scrollDownBy(1); // Prevent scroll jump when scrollable area is expanded
      for (let i = 0; i < messages.length; i++) {
        const { id, time, user, message, avatar } = messages[i];
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
          before: $('.bubble')[0],
          fadeIn: i === 0 ? 200 : 0
        });
        messageBubbles.unshift(messageBubble);
      }
      for (const message of messages) message.read = true;
      addBubbleContentListeners();
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

    function addEmoticonsToUi({ emoticons, forumIndex }) {
      if (currentForumIndex != forumIndex) return;
      emoticonPanel.update({ emoticons });
    }

    function addBBCodesToUi({ bbtags, forumIndex }) {
      if (currentForumIndex != forumIndex) return;
      bbcodesPanel.update({ bbtags });
    }

    function deleteMessage({ id, forumIndex, silent }) {
      if (currentForumIndex != forumIndex) return;
      const index = messageBubbles.findIndex((bubble) => bubble.id == id);
      if (index === -1) return;
      if ($(`#${messageBubbles[index].id}`))
        messageBubbles[index].remove(silent);
      messageBubbles.splice(index, 1);
    }

    async function editMessage({ message, forumIndex }) {
      if (currentForumIndex != forumIndex) return;
      if (!messageBubbles) return;
      const messageBubble = messageBubbles.find(
        (bubble) => bubble.id == message.id
      );
      if (!messageBubble) return;
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

    function isBottomVisible() {
      const messages = inMemoryStore.get('messages') || [];
      if (!messages.length) return true;
      const latestMessage = messages[messages.length - 1];
      return !!$(`#${latestMessage.id}`);
    }

    function toggleScrollButtonVisibility() {
      if (!isBottomVisible() || scrollUtil.isViewportNScreensAwayFromBottom(2))
        $('#scroll-to-bottom-circle').setAttribute('hide', 'false');
      else $('#scroll-to-bottom-circle').setAttribute('hide', 'true');
    }

    function showNavbar() {
      navbar.show();
      $('#text-panel').setAttribute('expanded', 'false');
      $('#emoticon-panel').setAttribute('expanded', 'false');
      $('#bbcodes-panel').setAttribute('expanded', 'false');
      $('#main-page').setAttribute('expanded', 'false');
      $('#scroll-to-bottom-circle').setAttribute('expanded', 'false');
      // Prevent scroll jump upon next hideNavbar call
      if (scrollUtil.isScrolledToBottom()) {
        scrollUtil.scrollUpBy(1);
        scrollToBottom();
      }
    }

    function hideNavbar() {
      navbar.hide();
      $('#text-panel').setAttribute('expanded', 'true');
      $('#emoticon-panel').setAttribute('expanded', 'true');
      $('#bbcodes-panel').setAttribute('expanded', 'true');
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
      scrollUtil.scrollToBottom(behavior);
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
      if (target.getAttribute('shaking') === 'true')
        cache.lastSelected = target;
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
      $('header').setAttribute('hide', 'true');
      toolsPanel.show();
    }

    function hideToolbar() {
      $('header').setAttribute('hide', 'false');
      toolsPanel.hide();
    }

    function onDestroy() {
      emoticonPanel.onDestroy();
      bbcodesPanel.onDestroy();
      infiniteScroll.onDestroy();
    }

    function addMessageSubmitListener(listen) {
      messageSubmitListeners.push({ listen });
    }

    function markMessagesAsRead(messages) {
      for (const message of messages) message.read = true;
    }

    function showProgressBar() {
      $('#progress-bar').setAttribute('hide', 'false');
    }

    function hideProgressBar() {
      $('#progress-bar').setAttribute('hide', 'true');
    }

    return {
      init,
      displayPage,
      addMessages,
      addOldMessages,
      buildMessagesHtml,
      addEmoticonsToUi,
      addBBCodesToUi,
      deleteMessage,
      editMessage,
      submitMessage,
      showNavbar,
      hideNavbar,
      scrollToBottom,
      showLoadingCircle,
      hideLoadingCircle,
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
      addMessageSubmitListener,
      rerenderPage,
      isBottomVisible,
      areNewMessagesVisible,
      showProgressBar,
      hideProgressBar
    };
  }

  window.modules = window.modules || {};
  window.modules.ChatUi = ChatUi;
})();
