import { PersistentStore } from '../../storage/persistent-store.js';
import { InMemoryStore } from '../../storage/in-memory-store.js';
import { ChatUi } from './scripts/chat-ui.js';
import { InfiniteScroll } from './scripts/infinite-scroll.js';
import { ScrollUtil } from '../../utils/scroll.js';
import { TouchEvents } from './scripts/touch-events.js';
import { DocumentUtil } from '../../utils/document.js';
import { AndroidUtil } from '../../utils/android.js';

async function Chat({
  el,
  config,
  globalSynchronizer,
  router,
  navbar,
  popups,
  badges
}) {
  const documentUtil = DocumentUtil();
  const androidUtil = AndroidUtil();
  const DEFAULT_FORUM_INDEX = '0';

  const forumIndex =
    documentUtil.getParam('forumIndex') ||
    PersistentStore('*').get('currentForumIndex') ||
    DEFAULT_FORUM_INDEX;
  const goToMessageId = documentUtil.getParam('goTo');
  PersistentStore('*').set('currentForumIndex', forumIndex);
  const forums = PersistentStore('*').get('forums');
  const { name, address, userId } = forums[+forumIndex];
  const forumStorage = PersistentStore(`${address}_${userId}`);
  const forumInMemoryStorage = InMemoryStore(`${address}_${userId}`);

  const infiniteScroll = InfiniteScroll({
    config,
    globalSynchronizer,
    currentForumIndex: forumIndex,
    baseUrl: address,
    loggedInUserId: userId
  });

  const chatUi = ChatUi({
    el,
    config,
    loggedInUserId: userId,
    forumName: name,
    baseUrl: address,
    currentForumIndex: forumIndex,
    navbar,
    forumStorage,
    infiniteScroll,
    popups,
    badges,
    router
  });

  document.getElementById('body').setAttribute('page', 'chat');

  const messages = forumInMemoryStorage.get('messages') || [];
  const emoticons = forumStorage.get('emoticons') || [];
  const bbtags = forumStorage.get('bbtags') || [];

  await chatUi.displayPage(messages, emoticons, bbtags, false, goToMessageId);
  chatUi.init();

  const touchEvents = TouchEvents(chatUi);
  const { eventTypes } = touchEvents;

  document.addEventListener('resume', attemptRerenderPage);
  document.addEventListener(
    eventTypes.TOUCHSTART,
    touchEvents.onBubbleTouchdown
  );
  document.addEventListener(eventTypes.TOUCHEND, touchEvents.onBubbleTouchend);
  document.addEventListener(
    eventTypes.LONGPRESS,
    touchEvents.onBubbleLongpress
  );
  document.addEventListener(
    eventTypes.TOUCHMOVE,
    touchEvents.onBubbleTouchmove
  );

  const addListenerId = globalSynchronizer.addSyncListener(
    'add',
    chatUi.addMessages
  );
  const addOldListenerId = globalSynchronizer.addSyncListener(
    'addOld',
    chatUi.addOldMessages
  );
  const deleteListenerId = globalSynchronizer.addSyncListener(
    'delete',
    chatUi.deleteMessage
  );
  const editListenerId = globalSynchronizer.addSyncListener(
    'edit',
    chatUi.editMessage
  );
  const errorListenerId = globalSynchronizer.addSyncListener(
    'syncError',
    chatUi.restoreSubmitMessage
  );
  const keyboardOnListenerId = androidUtil.addKeyboardOnListener(() => {
    const inputPromptPresent = document
      .getElementById('global-input-prompt')
      .classList.contains('active');
    chatUi.hideNavbar();
    if (inputPromptPresent) chatUi.hideInput();
    chatUi.toggleScrollButtonVisibility();
    if (
      chatUi.isBottomRendered() &&
      !ScrollUtil(
        document.getElementById('chat')
      ).isViewportNScreensAwayFromBottom(4) &&
      !inputPromptPresent
    )
      chatUi.scrollToBottom('smooth');
  });
  const keyboardOffListenerId = androidUtil.addKeyboardOffListener(() => {
    chatUi.showNavbar();
    chatUi.showInput();
    chatUi.toggleScrollButtonVisibility();
  });

  const newEmoticonsListenerId = globalSynchronizer.addSyncListener(
    'new-emoticons',
    chatUi.addEmoticonsToUi
  );

  const newBBCodesListenerId = globalSynchronizer.addSyncListener(
    'bbtags',
    chatUi.addBBCodesToUi
  );
  const archiveStartListenerId = globalSynchronizer.addSyncListener(
    'archiveStart',
    chatUi.showProgressBar
  );
  const archiveEndListenerId = globalSynchronizer.addSyncListener(
    'archiveEnd',
    chatUi.hideProgressBar
  );
  const archiveEndListener2Id = globalSynchronizer.addSyncListener(
    'archiveEnd',
    disableArchive
  );

  const messageSubmitListenerId = chatUi.addMessageSubmitListener((text) =>
    globalSynchronizer.sendToServer(forumIndex, text)
  );

  const messageDeleteListenerId = chatUi.toolsPanel.addMessageDeleteListener(
    (id) => {
      globalSynchronizer.deleteFromServer(forumIndex, id);
    }
  );

  const messageEditListenerId = chatUi.toolsPanel.addMessageEditListener(
    (id, text) => {
      globalSynchronizer.editOnServer(forumIndex, id, text);
    }
  );

  function disableArchive(event) {
    if (!event.error && event.forumIndex == forumIndex && !event.messages) {
      forumInMemoryStorage.set('archiveDisabled', true);
    }
  }

  async function attemptRerenderPage() {
    const messages = forumInMemoryStorage.get('messages') || [];
    if (!messages.length) return;
    chatUi.rerenderPage(true);
  }

  function onDestroy() {
    chatUi.showNavbar();
    globalSynchronizer.removeSyncListener(addListenerId);
    globalSynchronizer.removeSyncListener(addOldListenerId);
    globalSynchronizer.removeSyncListener(deleteListenerId);
    globalSynchronizer.removeSyncListener(editListenerId);
    globalSynchronizer.removeSyncListener(newEmoticonsListenerId);
    globalSynchronizer.removeSyncListener(newBBCodesListenerId);
    globalSynchronizer.removeSyncListener(archiveStartListenerId);
    globalSynchronizer.removeSyncListener(archiveEndListenerId);
    globalSynchronizer.removeSyncListener(archiveEndListener2Id);
    globalSynchronizer.removeSyncListener(errorListenerId);
    chatUi.removeMessageSubmitListener(messageSubmitListenerId);
    chatUi.toolsPanel.removeMessageDeleteListener(messageDeleteListenerId);
    chatUi.toolsPanel.removeMessageEditListener(messageEditListenerId);
    androidUtil.removeKeyboardOnListener(keyboardOnListenerId);
    androidUtil.removeKeyboardOffListener(keyboardOffListenerId);
    document.removeEventListener('resume', attemptRerenderPage);
    document.removeEventListener(
      eventTypes.TOUCHSTART,
      touchEvents.onBubbleTouchdown
    );
    document.removeEventListener(
      eventTypes.TOUCHEND,
      touchEvents.onBubbleTouchend
    );
    document.removeEventListener(
      eventTypes.LONGPRESS,
      touchEvents.onBubbleLongpress
    );
    document.removeEventListener(
      eventTypes.TOUCHMOVE,
      touchEvents.onBubbleTouchmove
    );
    chatUi.onDestroy();
  }

  router.addOnDestroy(onDestroy);
}

export { Chat };
