(function () {
  function MchatGlobalSynchronizer({
    PersistentStore,
    MchatSingleSynchronizer,
    CookieStore,
    MchatChatService,
    MchatUserService,
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
    document.addEventListener('resume', () => documentUtil.reloadImages());

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

    async function getArchiveMessages(forumIndex, startIndex) {
      const syncs = InMemoryStore('*').get('syncs') || [];
      const sync = syncs[forumIndex];
      await sync.getArchiveMessages(startIndex);
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
      listeners = listeners.filter((listener) => listener.id !== id);
    }

    return {
      startSync,
      stopSync,
      restartSync,
      addSyncListener,
      removeSyncListener,
      sendToServer,
      getArchiveMessages
    };
  }

  window.modules = window.modules || {};
  window.modules.MchatGlobalSynchronizer = MchatGlobalSynchronizer;
})();
