import { Languages } from '../../../languages/languages.js';
import { Message } from './message.js';
import { ScrollUtil } from '../../../utils/scroll.js';
import { InMemoryStore } from '../../../storage/in-memory-store.js';

function InfiniteScroll({
  config,
  globalSynchronizer,
  currentForumIndex,
  baseUrl,
  loggedInUserId
}) {
  const languages = Languages();
  const inMemoryStore = InMemoryStore(`${baseUrl}_${loggedInUserId}`);

  let scrollUtil;
  let messageBubbles;
  let archiveRequestBlocked = false;
  let onMessages;

  function init(_messageBubbles, _onMessages) {
    scrollUtil = ScrollUtil(document.getElementById('chat'));
    messageBubbles = _messageBubbles;
    onMessages = _onMessages;
    document.getElementById('chat').addEventListener('scroll', onScroll);
  }

  function onScroll() {
    const scrollPercentage = scrollUtil.getScrollPercentage();
    if (scrollPercentage <= 0.2) return onApproachingTop();
    if (!scrollUtil.isViewportNScreensAwayFromBottom(2.5))
      return onApproachingBottom();
  }

  async function onApproachingTop() {
    const oldestRenderedBubble = document.getElementsByClassName('bubble')[0];
    const index = inMemoryStore.findIndex(
      'messages',
      (m) => m.id == oldestRenderedBubble.id
    );
    let olderMessages = inMemoryStore.splice('messages', 0, index) || [];
    olderMessages = trimFromTopToLimit(olderMessages);
    const added = addMessagesToTop(olderMessages);
    removeExcessBottom();
    if (added) return; // don't call archive API if messages are added from memory
    if (archiveRequestBlocked || inMemoryStore.get('archiveDisabled')) return;
    /* Block access to the archive API when request is in progress to prevent request spam. */
    archiveRequestBlocked = true;
    /* phpBB archived messages are indexed differently than in this app.
      In the archive the older the message is, the greater index it has.
      It is the opposite in the memory store of this app. */
    const archiveIndex = inMemoryStore.getLength('messages');
    await globalSynchronizer.getArchiveMessages(
      currentForumIndex,
      archiveIndex,
      oldestRenderedBubble.id
    );
    archiveRequestBlocked = false;
  }

  function onApproachingBottom() {
    const latestRenderedBubble =
      document.getElementsByClassName('bubble')[
        document.getElementsByClassName('bubble').length - 1
      ];
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
    for (const { id, time, user, message, avatar } of messages.toReversed())
      if (id < messageBubbles[0].id) {
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
          before: document.getElementsByClassName('bubble')[0]
        });
        messageBubbles.unshift(messageBubble);
        added += 1;
      }
    if (onMessages) onMessages();
    return added;
  }

  function addMessagesToBottom(messages) {
    let added = 0;
    for (const { id, time, user, message, avatar } of messages)
      if (id > messageBubbles[messageBubbles.length - 1].id) {
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
          before: document.getElementById('chat-beginning')
        });
        messageBubbles.push(messageBubble);
        added += 1;
      }
    if (onMessages) onMessages();
    return added;
  }

  function removeExcessBottom() {
    const renderedBubbles = document.getElementsByClassName('bubble');
    while (renderedBubbles.length > config.MAX_MESSAGE_AMOUNT) {
      const index = messageBubbles.findIndex(
        (m) => m.id == renderedBubbles[renderedBubbles.length - 1].id
      );
      messageBubbles[index].remove(true);
      messageBubbles.splice(index, 1);
    }
  }

  function removeExcessTop() {
    const renderedBubbles = document.getElementsByClassName('bubble');
    while (renderedBubbles.length > config.MAX_MESSAGE_AMOUNT) {
      const index = messageBubbles.findIndex(
        (m) => m.id == renderedBubbles[0].id
      );
      messageBubbles[index].remove(true);
      messageBubbles.splice(index, 1);
    }
  }

  function onDestroy() {
    document.getElementById('chat').removeEventListener('scroll', onScroll);
  }

  return { init, onDestroy };
}

export { InfiniteScroll };
