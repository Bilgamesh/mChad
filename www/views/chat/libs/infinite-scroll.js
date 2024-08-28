(function () {
  function InfiniteScroll({
    globalSynchronizer,
    currentForumIndex,
    inMemoryStore,
    Message,
    baseUrl,
    languages,
    animationsUtil,
    documentUtil,
    sleep,
    loggedInUserId,
    config
  }) {
    let scrollUtil;
    let messageBubbles;
    let archiveRequestBlocked = false;

    function init(_scrollUtil, _messageBubbles) {
      scrollUtil = _scrollUtil;
      messageBubbles = _messageBubbles;
      $('#chat').addEventListener('scroll', onScroll);
    }

    function onScroll() {
      if ($('#chat').scrollTop < 10)
        $('#chat').scrollTo({
          top: 50,
          behavior: 'smooth'
        });
      const scrollPercentage = scrollUtil.getScrollPercentage();
      if (scrollPercentage <= 0.2) return onApproachingTop();
      if (!scrollUtil.isViewportNScreensAwayFromBottom(2.5))
        return onApproachingBottom();
    }

    async function onApproachingTop() {
      console.log('TOP');
      const oldestRenderedBubble = $('.bubble')[0];
      const index = inMemoryStore.findIndex(
        'messages',
        (m) => m.id == oldestRenderedBubble.id
      );
      let olderMessages = inMemoryStore.splice('messages', 0, index) || [];
      olderMessages = trimFromTopToLimit(olderMessages);
      const added = addMessagesToTop(olderMessages);
      removeExcessBottom();
      if (added) return; // don't call archive API if messages are added from memory
      if (archiveRequestBlocked) return;
      /* Block access to the archive API when request is in progress
      and few seconds after to prevent request spam. */
      archiveRequestBlocked = true;
      /* phpBB archived messages are indexed differently than in this app.
      In the archive the older the message is, the greater index it has.
      It is the opposite in the memory store of this app. */
      const archiveIndex = inMemoryStore.getLength('messages');
      await globalSynchronizer.getArchiveMessages(
        currentForumIndex,
        archiveIndex
      );
      onApproachingTop();
      setTimeout(() => {
        archiveRequestBlocked = false;
      }, 2 * 1000);
    }

    function onApproachingBottom() {
      console.log('BOTTOM');
      const latestRenderedBubble = $('.bubble')[$('.bubble').length - 1];
      const index = inMemoryStore.findIndex(
        'messages',
        (m) => m.id == latestRenderedBubble.id
      );
      let laterMessages = inMemoryStore.splice('messages', +index + 1) || [];
      laterMessages = trimFromBottomToLimit(laterMessages);
      addMessagesToBottom(laterMessages);
      removeExcessTop();
    }

    function trimFromTopToLimit(messages) {
      return messages.splice(messages.length - config.MAX_MESSAGE_AMOUNT / 5);
    }

    function trimFromBottomToLimit(messages) {
      return messages.splice(0, config.MAX_MESSAGE_AMOUNT / 5);
    }

    function addMessagesToTop(messages) {
      let added = 0;
      for (const { id, time, user, message, avatar } of messages)
        if (id < messageBubbles[0].id) {
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
            before: $('.bubble')[0]
          });
          messageBubbles.unshift(messageBubble);
          added += 1;
        }
      return added;
    }

    function addMessagesToBottom(messages) {
      let added = 0;
      for (const { id, time, user, message, avatar } of messages)
        if (id > messageBubbles[messageBubbles.length - 1].id) {
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
            before: $('#chat-beginning')
          });
          messageBubbles.push(messageBubble);
          added += 1;
        }
      return added;
    }

    function removeExcessBottom() {
      const renderedBubbles = $('.bubble');
      while (renderedBubbles.length > config.MAX_MESSAGE_AMOUNT) {
        // renderedBubbles[renderedBubbles.length - 1].remove();
        const index = messageBubbles.findIndex(
          (m) => m.id == renderedBubbles[renderedBubbles.length - 1].id
        );
        messageBubbles[index].remove(true);
        messageBubbles.splice(index, 1);
      }
    }

    function removeExcessTop() {
      const renderedBubbles = $('.bubble');
      while (renderedBubbles.length > config.MAX_MESSAGE_AMOUNT) {
        const index = messageBubbles.findIndex(
          (m) => m.id == renderedBubbles[0].id
        );
        messageBubbles[index].remove(true);
        messageBubbles.splice(index, 1);
      }
    }

    function onDestroy() {
      $('#chat').removeEventListener('scroll', onScroll);
    }

    return { init, onDestroy };
  }
  window.modules = window.modules || {};
  window.modules.InfiniteScroll = InfiniteScroll;
})();
