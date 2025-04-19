import { Message } from './message.js';
import { EmoticonPanel } from './emoticon-panel.js';
import { ToolsPanel } from './tools-panel.js';
import { BBCodesPanel } from './bbcodes-panel.js';
import { ScrollUtil } from '../../../utils/scroll.js';
import { Languages } from '../../../languages/languages.js';
import { sleep } from '../../../utils/sleep.js';
import { AndroidUtil } from '../../../utils/android.js';
import { HapticsUtil } from '../../../utils/haptics.js';
import { InMemoryStore } from '../../../storage/in-memory-store.js';

function ChatUi({
  el,
  config,
  loggedInUserId,
  forumName,
  baseUrl,
  currentForumIndex,
  navbar,
  infiniteScroll,
  forumStorage,
  popups,
  badges,
  router
}) {
  const androidUtil = AndroidUtil();

  const hapticsUtil = HapticsUtil();
  const languages = Languages();

  const inMemoryStore = InMemoryStore(`${baseUrl}_${loggedInUserId}`);

  const cache = { lastSelected: null };
  let messageSubmitListeners = [];
  let messageBubbles = [];
  const toolsPanel = ToolsPanel({
    baseUrl,
    chatUiCache: cache,
    inMemoryStore,
    forumStorage,
    popups
  });
  let emoticonPanel;
  let bbcodesPanel;
  let scrollUtil;
  let chatHeight;

  document.addEventListener('pause', rememberPosition);
  window.addEventListener('resize', updateChatHeight);

  document.getElementById('navbar-top-title').innerText = forumName || baseUrl;

  async function displayPage(
    messages,
    emoticons,
    bbtags,
    skipFadeAnimation,
    goToMessageId
  ) {
    if (!skipFadeAnimation) {
      /* Emptying the page just before re-rendering
        and giving browser an overhead via dummy timeout
        makes BeerCSS transition animations much smoother */
      el.innerHTML = '';
      await sleep(0);
    }

    /* Decide which state (messages) the chat should be rendered with.
      If chat view was entered by pressing a notification (hence goToMessageId was assigned),
      render chat position with that specific message visible at the bottom.
      If there was a state saved when user exited the chat last time, restore that.
      Else render the latest stored message, as the app must have been just opened from scratch */
    const { latestMessageId, messageCount, scrollHeight, inputText } =
      inMemoryStore.del('last-view-data') || {};
    if (goToMessageId) {
      messages = messages.filter(({ id }) => id <= goToMessageId);
      messages = messages.slice(messages.length - config.MAX_MESSAGE_AMOUNT);
    } else if (latestMessageId) {
      messages = messages.filter(({ id }) => id <= latestMessageId);
      messages = messages.slice(messages.length - messageCount);
    } else {
      messages = messages.slice(messages.length - config.MAX_MESSAGE_AMOUNT);
    }

    emoticonPanel = EmoticonPanel({
      emoticons
    });
    bbcodesPanel = BBCodesPanel({
      bbtags
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

      <div id="chat" class="chat active ${skipFadeAnimation ? '' : 'page'}">
        <br /><br />
        ${buildMessagesHtml(messages)}
        <div id="chat-beginning"></div>
        <br /><br /><br /><br /><br /><br /><br />
      </div>

      <button
        id="scroll-to-bottom-circle"
        class="circle medium fill ripple"
        hide="true"
      >
        <i>south</i>
      </button>

      ${emoticonPanel.getHtml()} ${bbcodesPanel.getHtml()}

      <div
        id="text-panel"
        class="${skipFadeAnimation
          ? ''
          : 'page'} bottom text-panel ${messages.length ? 'active' : ''}"
      >
        <form id="chat-form">
          <div id="text-field" class="field label fill small round">
            <input id="input-box" type="text" class="text-field" />
            <label
              id="input-label"
              class="${inputText ? 'no-transition-label' : ''}"
              >${await languages.getTranslation('TYPE_SOMETHING')}
              <span id="limit-info"></span
            ></label>
            <i id="bbcodes-panel-icon" class="bbcodes-panel-icon">code</i>
            <i id="emoji-icon" class="emoji-icon">emoticon</i>
          </div>
        </form>
      </div>
    `;

    chatHeight = document.getElementById('chat').clientHeight;
    document.getElementById('input-box').value = inputText || '';
    updateMesageLimitInfo();
    addBubbleContentListeners();
    if (scrollHeight && !goToMessageId) scrollToInstant(scrollHeight);
    else if (scrollHeight !== 0) scrollToBottom('instant');
  }

  function init() {
    scrollUtil = ScrollUtil(document.getElementById('chat'));
    registerHaptics();
    registerButtons();
    registerListeners();
    emoticonPanel.registerListeners();
    bbcodesPanel.registerListeners();
    if (document.getElementsByClassName('bubble').length)
      infiniteScroll.init(messageBubbles, addBubbleContentListeners);
  }

  function registerHaptics() {
    document
      .getElementById('emoji-icon')
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById('bbcodes-panel-icon')
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById('scroll-to-bottom-circle')
      .addEventListener('click', hapticsUtil.tapDefault);
    for (const toolItem of document.getElementsByClassName('tool-item'))
      toolItem.addEventListener('click', hapticsUtil.tapDefault);
  }

  function registerButtons() {
    document
      .getElementById('scroll-to-bottom-circle')
      .addEventListener('click', onScrollToBottomClicked);
    document
      .getElementById('chat')
      .addEventListener('scroll', toggleScrollButtonVisibility);
    document
      .getElementById('chat-form')
      .addEventListener('submit', submitMessage);
    toolsPanel.registerListeners();
  }

  function onScrollToBottomClicked() {
    rememberInputText();
    hideToolbar();
    if (isBottomRendered()) scrollToBottom('smooth');
    else rerenderPage();
  }

  function registerListeners() {
    document.getElementById('chat').addEventListener('scroll', refreshBadges);
    document
      .getElementById('chat')
      .addEventListener('scroll', attemptHideToolbar);
    document
      .getElementById('text-field')
      .addEventListener('click', enableInputLabelAnimation);
    document
      .getElementById('input-box')
      .addEventListener('input', updateMesageLimitInfo);
  }

  function updateChatHeight() {
    chatHeight = document.getElementById('chat')?.clientHeight;
  }

  function attemptHideToolbar() {
    if (!document.querySelector('[shaking="true"]')) hideToolbar();
  }

  function refreshBadges() {
    const messages = inMemoryStore.get('messages');
    markSeenMessagesAsRead(messages);
    badges.refreshBadges();
  }

  function enableInputLabelAnimation() {
    document
      .getElementById('input-label')
      .classList.remove('no-transition-label');
  }

  async function rerenderPage(skipFadeAnimation) {
    const messages = inMemoryStore.get('messages') || [];
    const emoticons = forumStorage.get('emoticons') || [];
    const bbtags = forumStorage.get('bbtags') || [];
    messageBubbles.length = 0;
    emoticonPanel.onDestroy();
    bbcodesPanel.onDestroy();
    infiniteScroll.onDestroy();
    await displayPage(messages, emoticons, bbtags, skipFadeAnimation);
    init();
  }

  function addMessages({ messages, scrollType, forumIndex }) {
    if (currentForumIndex != forumIndex) return;
    const isFirstBatch = !document.getElementsByClassName('bubble').length;
    if (isFirstBatch) return rerenderPage(false);
    if (scrollUtil.isViewportNScreensAwayFromBottom(2)) return;
    messages = messages.filter((m) => !isAlreadyAdded(m));
    messages = messages.slice(messages.length - config.MAX_MESSAGE_AMOUNT);
    if (scrollUtil.isScrolledToBottom()) scrollUtil.scrollUpBy(1); // Prevent scroll jump when scrollable area is expanded
    for (const message of messages) {
      if (isBottomVisible()) message.read = true;
      const messageBubble = Message({
        el: document.getElementById('chat'),
        side: message.user.id === loggedInUserId ? 'right' : 'left',
        id: message.id,
        time: message.time,
        user: message.user,
        message: message.message,
        baseUrl,
        avatar: message.avatar
      });
      messageBubble.insertElement({
        before: document.getElementById('chat-beginning'),
        fadeIn: 200
      });
      messageBubbles.push(messageBubble);
    }
    addBubbleContentListeners();
    if (
      messages.length > 0 &&
      !scrollUtil.isViewportNScreensAwayFromBottom(2)
    ) {
      scrollToBottom(scrollType || 'smooth');
    }
  }

  async function addOldMessages({ messages, forumIndex, oldestMessageId }) {
    if (document.getElementsByClassName('bubble')[0].id !== oldestMessageId) return; // Do not render message from the archive if user has scrolled down too far
    messages = messages.filter((m) => !isAlreadyAdded(m));
    messages = messages.slice(0, config.MAX_MESSAGE_AMOUNT);
    if (currentForumIndex != forumIndex) return;
    if (scrollUtil.isScrolledToTop()) scrollUtil.scrollDownBy(1); // Prevent scroll jump when scrollable area is expanded
    for (let i = 0; i < messages.length; i++) {
      const { id, time, user, message, avatar } = messages[i];
      const messageBubble = Message({
        el: document.getElementById('chat'),
        side: user.id === loggedInUserId ? 'right' : 'left',
        id,
        time,
        user,
        message,
        baseUrl,
        avatar
      });
      messageBubble.insertElement({
        before: document.getElementsByClassName('bubble')[0],
        fadeIn: i === 0 ? 200 : 0
      });
      messageBubbles.unshift(messageBubble);
    }
    for (const message of messages) message.read = true;
    addBubbleContentListeners();
  }

  function isAlreadyAdded({ id }) {
    const addedMessages = document.getElementsByClassName('bubble');
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
        avatar
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
    if (document.getElementById(`${messageBubbles[index].id}`))
      messageBubbles[index].remove(silent);
    messageBubbles.splice(index, 1);
  }

  async function editMessage({ message, forumIndex }) {
    if (currentForumIndex != forumIndex) return;
    if (!messageBubbles) return;
    const messageBubble = messageBubbles.find(({ id }) => id == message.id);
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
        image.addEventListener('click', openInImageViewer);
        image.setAttribute('listener', 1);
      }
  }

  function openInImageViewer(event) {
    const url = event.srcElement.currentSrc;
    router.redirect(`#image?url=${btoa(url)}`);
  }

  function addLinkListeners() {
    const links = document.querySelectorAll('a.clickable-link');
    for (const link of links)
      if (link.getAttribute('listener') != 1) {
        link.addEventListener('click', () =>
          androidUtil.openInBrowser(link.getAttribute('target-url'), '_system')
        );
        link.setAttribute('listener', 1);
      }
  }

  function submitMessage(event) {
    event.preventDefault();
    const text = document.getElementById('text-field').children[0].value || '';
    document.getElementById('text-field').children[0].value = '';
    updateMesageLimitInfo();
    androidUtil.hideKeyboard(document.getElementById('text-field'));
    document.activeElement.blur();
    if (!text.trim()) return;
    for (const listener of messageSubmitListeners) {
      listener.listen(text);
    }
  }

  function isBottomRendered() {
    const messages = inMemoryStore.get('messages') || [];
    if (!messages.length) return true;
    const latestMessage = messages[messages.length - 1];
    return !!document.getElementById(`${latestMessage.id}`);
  }

  function isBottomVisible() {
    const messageBubbles = document.getElementsByClassName('bubble');
    if (!messageBubbles.length) return true;
    const latestMessageBubble = messageBubbles[messageBubbles.length - 1];
    return chatHeight > latestMessageBubble.getBoundingClientRect().y;
  }

  function toggleScrollButtonVisibility() {
    if (!isBottomRendered() || scrollUtil.isViewportNScreensAwayFromBottom(2))
      document
        .getElementById('scroll-to-bottom-circle')
        ?.setAttribute('hide', 'false');
    else
      document
        .getElementById('scroll-to-bottom-circle')
        ?.setAttribute('hide', 'true');
  }

  function showNavbar() {
    navbar.show();
    document.getElementById('text-panel').setAttribute('expanded', 'false');
    document.getElementById('emoticon-panel').setAttribute('expanded', 'false');
    document.getElementById('bbcodes-panel').setAttribute('expanded', 'false');
    document.getElementById('main-page').setAttribute('expanded', 'false');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('expanded', 'false');
    // Prevent scroll jump upon next hideNavbar call
    scrollUtil.scrollUpBy(1);
    scrollUtil.scrollDownBy(1);
  }

  function hideNavbar() {
    navbar.hide();
    document.getElementById('text-panel').setAttribute('expanded', 'true');
    document.getElementById('emoticon-panel').setAttribute('expanded', 'true');
    document.getElementById('bbcodes-panel').setAttribute('expanded', 'true');
    document.getElementById('main-page').setAttribute('expanded', 'true');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('expanded', 'true');
  }

  function hideInput() {
    document.getElementById('main-page').setAttribute('expanded', 'true');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('hide', 'true');
    document.getElementById('text-panel').setAttribute('hide', 'true');
  }

  function showInput() {
    document.getElementById('main-page').setAttribute('expanded', 'false');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('hide', 'false');
    document.getElementById('text-panel').setAttribute('hide', 'false');
  }

  async function scrollToBottom(behavior) {
    if (!document.getElementById('chat')) return;
    if (behavior === 'instant') {
      do {
        document.getElementById('chat').scrollTop =
          document.getElementById('chat').scrollHeight;
        await sleep(0); // gives browser overhead for rendering when height of the chat is not rendered yet
      } while (document.getElementById('chat')?.scrollTop === 0);
      return;
    }
    scrollUtil.scrollToBottom(behavior);
  }

  async function scrollToInstant(height) {
    do {
      document.getElementById('chat').scrollTop = height;
    } while (document.getElementById('chat').scrollTop === 0);
  }

  function startShaking(target) {
    if (target.classList.contains('bubble'))
      target.setAttribute('shaking', 'true');
  }

  function stopShaking(target) {
    if (target.getAttribute('shaking') === 'true') cache.lastSelected = target;
    target.setAttribute('shaking', 'false');
  }

  function stopShakingAllBubbles() {
    for (const element of document.getElementsByClassName('bubble'))
      stopShaking(element);
  }

  function shrinkAllBubbles() {
    for (const element of document.getElementsByClassName('bubble'))
      element.setAttribute('enlarged', 'false');
  }

  function showToolbar(bubble) {
    document.querySelector('header').setAttribute('hide', 'true');
    toolsPanel.show(bubble);
  }

  function hideToolbar() {
    document.querySelector('header').setAttribute('hide', 'false');
    toolsPanel.hide();
  }

  /* Called when exiting the chat view or minimizing the app.
    Store last UI state before exiting so it can be restored
    when user re-enters the chat view */
  function rememberPosition() {
    const bubbles = document.getElementsByClassName('bubble');
    if (!bubbles.length) return;
    const oldestMessageId = bubbles[0].id;
    const latestMessageId = bubbles[bubbles.length - 1].id;
    const scrollHeight = document.getElementById('chat').scrollTop;
    const inputText = (document.getElementById('input-box').value || '').trim();
    inMemoryStore.set('last-view-data', {
      oldestMessageId,
      latestMessageId,
      messageCount: bubbles.length,
      scrollHeight,
      inputText
    });
  }

  function rememberInputText() {
    const inputText = (document.getElementById('input-box').value || '').trim();
    inMemoryStore.set('last-view-data', {
      inputText
    });
  }

  function onDestroy() {
    document.removeEventListener('pause', rememberPosition);
    rememberPosition();
    emoticonPanel.onDestroy();
    bbcodesPanel.onDestroy();
    infiniteScroll.onDestroy();
    window.removeEventListener('resize', updateChatHeight);
  }

  function addMessageSubmitListener(listen) {
    const id = crypto.randomUUID();
    messageSubmitListeners.push({ id, listen });
    return id;
  }

  function removeMessageSubmitListener(id) {
    messageSubmitListeners = messageSubmitListeners.filter(
      (listener) => listener.id !== id
    );
  }

  /* Iterate over all messages that are rendered on screen and mark as "read" those,
    which are located above the bottom edge of the screen.
    If no message is below the bottom edge of the screen, mark all of them as read. */
  function markSeenMessagesAsRead(messages) {
    if (inMemoryStore.get('chat-badge') === 0) return;
    let topmostUnreadMessageId;
    let lastRenderedMessageId;
    for (const bubble of document.getElementsByClassName('bubble')) {
      lastRenderedMessageId = bubble.id;
      const isAboveBottomEdge = chatHeight > bubble.getBoundingClientRect().y;
      if (!isAboveBottomEdge) {
        topmostUnreadMessageId = +bubble.id;
        break;
      }
    }
    messages = messages.filter(({ id }) => id <= lastRenderedMessageId);
    for (const message of messages) {
      if (!topmostUnreadMessageId || message.id < topmostUnreadMessageId)
        message.read = true;
    }
  }

  function restoreSubmitMessage({ forumIndex, text }) {
    if (
      !text ||
      currentForumIndex != forumIndex ||
      document.getElementById('input-box').value
    )
      return;
    document.getElementById('input-box').value = text;
    updateMesageLimitInfo();
  }

  function showProgressBar() {
    document.getElementById('progress-bar').setAttribute('hide', 'false');
  }

  function hideProgressBar() {
    document.getElementById('progress-bar').setAttribute('hide', 'true');
  }

  function updateMesageLimitInfo() {
    const limit = forumStorage.get('messageLimit') || 0;
    if (!limit) {
      document.getElementById('limit-info').innerText = '';
      return;
    }
    const text = document.getElementById('input-box').value || '';
    const length = text.length;
    if (length / limit < 0.9) {
      document.getElementById('limit-info').innerText = '';
      return;
    }
    document.getElementById('limit-info').innerText = `${length}/${limit}`;
  }

  return {
    init,
    displayPage,
    addMessages,
    addOldMessages,
    addEmoticonsToUi,
    addBBCodesToUi,
    deleteMessage,
    editMessage,
    showNavbar,
    hideNavbar,
    scrollToBottom,
    startShaking,
    stopShaking,
    stopShakingAllBubbles,
    shrinkAllBubbles,
    showToolbar,
    hideToolbar,
    toggleScrollButtonVisibility,
    onDestroy,
    addMessageSubmitListener,
    removeMessageSubmitListener,
    rerenderPage,
    isBottomRendered,
    restoreSubmitMessage,
    showProgressBar,
    hideProgressBar,
    showInput,
    hideInput,
    toolsPanel
  };
}

export { ChatUi };
