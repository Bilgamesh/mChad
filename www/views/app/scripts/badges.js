(function () {
  function NavbarBadges({
    navbar,
    documentUtil,
    PersistentStore,
    InMemoryStore
  }) {
    const allUnreadMessagesLists = [];

    function updateChatBadgeInfo(currentForumIndex) {
      const pageHash = location.hash.split('?')[0];
      const unreadMessages = getForumSpecificUnreadMessages(currentForumIndex);
      const forums = PersistentStore('*').get('forums');
      const forum = (forums || [])[currentForumIndex];
      if (forum)
        InMemoryStore(`${forum.address}_${forum.userId}`).set(
          'chat-badge',
          unreadMessages.length
        );
      if (pageHash === '#chat' && unreadMessages > 0) return;
      navbar.displayBadge({
        element: $('#chat-btn'),
        id: 'chat-badge',
        number: unreadMessages.length
      });
    }

    function updateAccountsBadgeInfo(currentForumIndex) {
      let otherUnreadMessages = [];
      const forums = PersistentStore('*').get('forums');
      for (let i = 0; i < forums.length; i++)
        if (i != currentForumIndex) {
          const unreadMessages = getForumSpecificUnreadMessages(i);
          otherUnreadMessages = [...otherUnreadMessages, ...unreadMessages];
        }
      navbar.displayBadge({
        element: $('#accounts-btn'),
        id: 'accounts-badge',
        number: otherUnreadMessages.length
      });
    }

    function removeReadMessagesFromUnreadList() {
      for (const [index] of allUnreadMessagesLists.entries()) {
        allUnreadMessagesLists[index] = allUnreadMessagesLists[index].filter(
          (m) => !m.read
        );
      }
    }

    function removeDeletedMessagesFromUnreadList() {
      const forums = PersistentStore('*').get('forums');
      for (const [index] of allUnreadMessagesLists.entries()) {
        const forum = forums[index];
        if (!forum) continue;
        const forumStorage = InMemoryStore(`${forum.address}_${forum.userId}`);
        const messages = forumStorage.get('messages') || [];
        allUnreadMessagesLists[index] = allUnreadMessagesLists[index].filter(
          (m) => messages.includes(m)
        );
      }
    }

    function getNewUnreadMessages(index, forum) {
      const forumStorage = InMemoryStore(`${forum.address}_${forum.userId}`);
      const messages = forumStorage.get('messages') || [];
      const unreadMessages = messages.filter((m) => !m.read);
      const allUnreadMessages = allUnreadMessagesLists[index] || [];
      const newUnreadMessages = unreadMessages.filter(
        (m) => !allUnreadMessages.includes(m)
      );
      return newUnreadMessages;
    }

    function getForumSpecificUnreadMessages(forumIndex) {
      const categories = allUnreadMessagesLists;
      categories[forumIndex] = categories[forumIndex] || [];
      return categories[forumIndex];
    }

    function updateUnreadMessagesList() {
      removeReadMessagesFromUnreadList();
      removeDeletedMessagesFromUnreadList();
      const forums = PersistentStore('*').get('forums');
      for (const [index, forum] of forums.entries()) {
        const newUnreadMessages = getNewUnreadMessages(index, forum);
        const forumUnreadMessages = getForumSpecificUnreadMessages(index);
        for (const unreadMessage of newUnreadMessages)
          forumUnreadMessages.push(unreadMessage);
      }
    }

    function refreshBadges() {
      const DEFAULT_FORUM_INDEX = '0';
      const currentForumIndex = +(
        documentUtil.getParam('forumIndex') ||
        PersistentStore('*').get('currentForumIndex') ||
        DEFAULT_FORUM_INDEX
      );
      updateUnreadMessagesList();
      updateChatBadgeInfo(currentForumIndex);
      updateAccountsBadgeInfo(currentForumIndex);
    }

    return {
      refreshBadges,
      getForumSpecificUnreadMessages,
      updateUnreadMessagesList
    };
  }
  window.modules = window.modules || {};
  window.modules.NavbarBadges = NavbarBadges;
})();
