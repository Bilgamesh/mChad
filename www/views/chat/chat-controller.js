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
    ChatEvents,
    InMemoryStore,
    events,
    sleep,
    navbar,
    Message,
    Emoticon,
    badges,
    EmoticonPanel,
    ToolsPanel,
    BBCode,
    BBCodesPanel,
    clipboardUtil,
    ScrollUtil,
    InfiniteScroll
  }) {
    const DEFAULT_FORUM_INDEX = '0';

    const forumIndex =
      documentUtil.getParam('forumIndex') ||
      PersistentStore('*').get('currentForumIndex') ||
      DEFAULT_FORUM_INDEX;
    PersistentStore('*').set('currentForumIndex', forumIndex);
    const forums = PersistentStore('*').get('forums');
    const { name, address, userId } = forums[+forumIndex];
    const forumStorage = PersistentStore(`${address}_${userId}`);
    const forumInMemoryStorage = InMemoryStore(`${address}_${userId}`);

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
      InfiniteScroll,
      getLikeMessage: () => forumInMemoryStorage.get('likeMessage')
    });

    $('#body').setAttribute('page', 'chat');

    const messages = forumInMemoryStorage.get('messages') || [];
    const emoticons = forumStorage.get('emoticons') || [];
    const bbtags = forumStorage.get('bbtags') || [];

    markMessagesAsRead({ messages, forumIndex });

    await chatUi.displayPage(messages, emoticons, bbtags);
    const scrollUtil = ScrollUtil($('#chat'));
    chatUi.init(scrollUtil);

    const chatEvents = ChatEvents(chatUi, hapticsUtil);

    document.addEventListener('resume', attemptRerenderPage);
    document.addEventListener(events.TOUCHSTART, chatEvents.onBubbleTouchdown);
    document.addEventListener(events.TOUCHEND, chatEvents.onBubbleTouchend);
    document.addEventListener(events.LONGPRESS, chatEvents.onBubbleLongpress);
    document.addEventListener(events.TOUCHMOVE, chatEvents.onBubbleTouchmove);

    $('#chat').addEventListener('touchstart', badges.refreshBadges);

    const addListenerId = globalSynchronizer.addSyncListener(
      'add',
      chatUi.addMessages
    );
    const addListenerMessageMarkerId = globalSynchronizer.addSyncListener(
      'add',
      markMessagesAsRead
    );
    const deleteListenerId = globalSynchronizer.addSyncListener(
      'delete',
      chatUi.deleteMessage
    );
    const editListenerId = globalSynchronizer.addSyncListener(
      'edit',
      chatUi.editMessage
    );
    const keyboardOnListenerId = androidUtil.addKeyboardOnListener(() => {
      chatUi.hideNavbar();
      chatUi.scrollToBottom('smooth');
    });
    const keyboardOffListenerId = androidUtil.addKeyboardOffListener(
      chatUi.showNavbar
    );

    const newEmoticonsListenerId = globalSynchronizer.addSyncListener(
      'new-emoticons',
      chatUi.addEmoticonsToUi
    );

    const newBBCodesListenerId = globalSynchronizer.addSyncListener(
      'bbtags',
      chatUi.addBBCodesToUi
    );

    chatUi.addMessageSubmitListener((text) =>
      globalSynchronizer.sendToServer(forumIndex, text)
    );

    function markMessagesAsRead({ messages, forumIndex: i }) {
      if (forumIndex != i) return;
      for (const message of messages) message.read = true;
    }

    async function attemptRerenderPage() {
      const messages = forumInMemoryStorage.get('messages') || [];
      markMessagesAsRead({ messages, forumIndex });
      const latestMessage = messages[messages.length - 1];
      const alreadyRenderedMessages = $('.bubble');
      const latestRenderedMessage =
        alreadyRenderedMessages[alreadyRenderedMessages.length - 1];
      if (latestMessage.id == latestRenderedMessage.id) return;
      const emoticons = forumStorage.get('emoticons') || [];
      const bbtags = forumStorage.get('bbtags') || [];
      await chatUi.displayPage(messages, emoticons, bbtags);
      chatUi.init();
    }

    function onDestroy() {
      $('#chat').removeEventListener('touchstart', badges.refreshBadges);
      globalSynchronizer.removeSyncListener(addListenerId);
      globalSynchronizer.removeSyncListener(addListenerMessageMarkerId);
      globalSynchronizer.removeSyncListener(deleteListenerId);
      globalSynchronizer.removeSyncListener(editListenerId);
      globalSynchronizer.removeSyncListener(newEmoticonsListenerId);
      globalSynchronizer.removeSyncListener(newBBCodesListenerId);
      androidUtil.removeKeyboardOnListener(keyboardOnListenerId);
      androidUtil.removeKeyboardOffListener(keyboardOffListenerId);
      document.removeEventListener('resume', attemptRerenderPage);
      document.removeEventListener(
        events.TOUCHSTART,
        chatEvents.onBubbleTouchdown
      );
      document.removeEventListener(
        events.TOUCHEND,
        chatEvents.onBubbleTouchend
      );
      document.removeEventListener(
        events.LONGPRESS,
        chatEvents.onBubbleLongpress
      );
      document.removeEventListener(
        events.TOUCHMOVE,
        chatEvents.onBubbleTouchmove
      );
      chatUi.onDestroy();
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Chat = Chat;
})();
