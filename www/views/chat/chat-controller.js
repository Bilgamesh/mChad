(function () {
  async function Chat({
    el,
    languages,
    PersistentStore,
    globalSynchronizer,
    documentUtil,
    router,
    androidUtil,
    ChatUi,
    animationsUtil,
    hapticsUtil,
    TouchEvents,
    InMemoryStore,
    sleep,
    navbar,
    Message,
    Emoticon,
    EmoticonPanel,
    ToolsPanel,
    BBCode,
    BBCodesPanel,
    clipboardUtil,
    ScrollUtil,
    InfiniteScroll,
    config,
    popups,
    badges
  }) {
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
      globalSynchronizer,
      currentForumIndex: forumIndex,
      inMemoryStore: forumInMemoryStorage,
      Message,
      baseUrl: address,
      languages,
      animationsUtil,
      documentUtil,
      sleep,
      loggedInUserId: userId,
      config
    });

    const chatUi = ChatUi({
      el,
      loggedInUserId: userId,
      forumName: name,
      baseUrl: address,
      currentForumIndex: forumIndex,
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
      ScrollUtil,
      config,
      inMemoryStore: forumInMemoryStorage,
      forumStorage,
      infiniteScroll,
      popups,
      badges,
      router
    });

    $('#body').setAttribute('page', 'chat');

    const messages = forumInMemoryStorage.get('messages') || [];
    const emoticons = forumStorage.get('emoticons') || [];
    const bbtags = forumStorage.get('bbtags') || [];

    await chatUi.displayPage(messages, emoticons, bbtags, false, goToMessageId);
    chatUi.init();

    const touchEvents = TouchEvents(chatUi, hapticsUtil);
    const { eventTypes } = touchEvents;

    document.addEventListener('resume', attemptRerenderPage);
    document.addEventListener(
      eventTypes.TOUCHSTART,
      touchEvents.onBubbleTouchdown
    );
    document.addEventListener(
      eventTypes.TOUCHEND,
      touchEvents.onBubbleTouchend
    );
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
      const inputPromptPresent = $('#global-input-prompt').classList.contains(
        'active'
      );
      chatUi.hideNavbar();
      if (inputPromptPresent) chatUi.hideInput();
      if (
        chatUi.isBottomRendered() &&
        !ScrollUtil($('#chat')).isViewportNScreensAwayFromBottom(4) &&
        !inputPromptPresent
      )
        chatUi.scrollToBottom('smooth');
    });
    const keyboardOffListenerId = androidUtil.addKeyboardOffListener(() => {
      chatUi.showNavbar();
      chatUi.showInput();
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
  window.modules = window.modules || {};
  window.modules.Chat = Chat;
})();
