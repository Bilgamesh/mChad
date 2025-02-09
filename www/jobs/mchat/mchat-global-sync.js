(function () {
  function MchatGlobalSynchronizer({
    PersistentStore,
    MchatSingleSynchronizer,
    CookieStore,
    MchatChatService,
    MchatUserService,
    MchatOnlineUsersService,
    MchatEmoticonsService,
    InMemoryStore,
    fetchTool,
    config,
    documentUtil,
    languages,
    popups,
    Timer
  }) {
    let listeners = [];
    const globalStore = InMemoryStore('*');

    document.addEventListener('pause', stopSync);
    document.addEventListener('resume', restartSync);

    function startSync() {
      console.log(`[${new Date().toLocaleString()}][ALL] START SYNC`);
      const forums = PersistentStore('*').get('forums') || [];
      for (const [index, forum] of forums.entries()) {
        const cookieStore = CookieStore(
          `${forum.address}_${forum.userId}`,
          PersistentStore
        );
        const sync = MchatSingleSynchronizer({
          forum,
          cookieStore,
          forumIndex: `${index}`,
          PersistentStore,
          MchatChatService,
          MchatOnlineUsersService,
          MchatUserService,
          MchatEmoticonsService,
          InMemoryStore,
          fetchTool,
          config,
          documentUtil,
          languages,
          popups,
          Timer
        });
        sync.addSyncListener('*', (e) => {
          for (const allSyncsListener of listeners) allSyncsListener.listen(e);
        });
        sync.startSync();
        globalStore.add('syncs', sync);
      }
    }

    function stopSync() {
      console.log(`[${new Date().toLocaleString()}][ALL] STOP SYNC`);
      const syncs = globalStore.get('syncs') || [];
      for (const sync of syncs) sync.stopSync();
      globalStore.del('syncs');
    }

    function restartSync() {
      console.log(`[${new Date().toLocaleString()}][ALL] RESTART SYNC`);
      stopSync();
      startSync();
    }

    async function sendToServer(index, text) {
      const syncs = InMemoryStore('*').get('syncs') || [];
      const sync = syncs[index];
      await sync.sendToServer(text);
    }

    async function deleteFromServer(index, id) {
      const syncs = InMemoryStore('*').get('syncs') || [];
      const sync = syncs[index];
      sync.deleteFromServer(id);
    }

    async function editOnServer(index, id, message) {
      const syncs = InMemoryStore('*').get('syncs') || [];
      const sync = syncs[index];
      sync.editOnServer(id, message);
    }

    async function getArchiveMessages(forumIndex, startIndex, oldestMessageId) {
      const syncs = InMemoryStore('*').get('syncs') || [];
      const sync = syncs[forumIndex];
      await sync.getArchiveMessages(startIndex, oldestMessageId);
    }

    function addSyncListener(event, listen) {
      const id = crypto.randomUUID();
      if (event === '*') listeners.push({ listen, id });
      else
        listeners.push({
          listen: (o) => {
            if (o.event === event) listen(o);
          },
          id
        });

      return id;
    }

    function removeSyncListener(id) {
      const index = listeners.findIndex((listener) => listener.id === id);
      if (index !== -1) listeners.splice(index, 1);
    }

    return {
      startSync,
      stopSync,
      restartSync,
      addSyncListener,
      removeSyncListener,
      sendToServer,
      deleteFromServer,
      editOnServer,
      getArchiveMessages
    };
  }

  window.modules = window.modules || {};
  window.modules.MchatGlobalSynchronizer = MchatGlobalSynchronizer;
})();
