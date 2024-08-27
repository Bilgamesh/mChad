(async function () {
  function BackgroundSynchronizer({
    PersistentStore,
    MchatChatService,
    CookieStore,
    InMemoryStore,
    fetchTool,
    config,
    documentUtil
  }) {
    const preferencesStore = PersistentStore('app-preferences');
    const syncListeners = [];
    let backgroundMode = false;

    document.addEventListener('pause', () => {
      backgroundMode = true;
    });
    document.addEventListener('resume', () => {
      backgroundMode = false;
    });

    async function init() {
      const status = await window.BackgroundFetch.configure(
        {
          minimumFetchInterval: 15,
          requiredNetworkType: BackgroundFetch.NETWORK_TYPE_ANY
        },
        async (taskId) => {
          // <-- Event callback.
          // This is the task callback.
          try {
            if (preferencesStore.get('local-notifications') && backgroundMode) {
              const refreshDatas = await refreshAll();
              for (const refreshData of refreshDatas)
                await broadcastToAllListeners(refreshData);
            }
          } catch (err) {
            console.log(`[${new Date().toLocaleString()}][BACKGROUND-SYNC] Error: ${err}`);
          } finally {
            window.BackgroundFetch.finish(taskId);
          }
        },
        async (taskId) => {
          // <-- Event timeout callback
          // This task has exceeded its allowed running-time.
          // You must stop what you're doing and immediately .finish(taskId)
          window.BackgroundFetch.finish(taskId);
        }
      );
    }

    async function broadcastToAllListeners(data) {
      for (const listener of syncListeners) await listener.listen(data);
    }

    function addSyncListener(listen) {
      syncListeners.push({ listen });
    }

    async function refreshAll() {
      const refreshDatas = [];
      const forums = PersistentStore('*').get('forums') || [];
      for (const [index, forum] of forums.entries()) {
        const inMemoryStore = InMemoryStore(`${forum.address}_${forum.userId}`);
        const cookieStore = CookieStore(
          `${forum.address}_${forum.userId}`,
          PersistentStore
        );
        const chatService = MchatChatService({
          baseUrl: forum.address,
          cookieStore,
          fetchTool,
          documentUtil
        });
        const existingMessages = inMemoryStore.get('messages') || [];
        const latestMessage = existingMessages[existingMessages.length - 1];
        const { cookie, add, edit, del, log } = await chatService.refresh(
          latestMessage.id,
          inMemoryStore.get('logId')
        );
        if (cookie) await cookieStore.set(cookie);
        if (log) inMemoryStore.set('logId', log);
        if (edit) onEdit(inMemoryStore, edit);
        if (del) onDel(inMemoryStore, del);
        if (add) {
          onAdd(inMemoryStore, add);
          refreshDatas.push({
            messages: add,
            forumName: forum.name || forum.address,
            baseUrl: forum.address,
            forumIndex: index,
            userId: forum.userId
          });
        }
      }
      return refreshDatas;
    }

    function onDel(inMemoryStore, ids) {
      const messages = inMemoryStore.get('messages');
      for (const id of ids) {
        const index = messages.findIndex((m) => m.id == id);
        if (index !== -1) inMemoryStore.del('messages', index);
      }
    }

    function onEdit(inMemoryStore, messages) {
      const existingMessages = inMemoryStore.get('messages') || [];
      for (const message of messages) {
        const index = existingMessages.findIndex((m) => m.id == message.id);
        if (index !== -1) inMemoryStore.set('messages', message, index);
      }
    }

    function onAdd(inMemoryStore, messages) {
      for (const message of messages)
        if (!inMemoryStore.contains('messages', (m) => m.id == message.id))
          inMemoryStore.add('messages', message);
      inMemoryStore.sort('messages', (a, b) => a.id - b.id);
      if (inMemoryStore.get('messages').length > config.MAX_MESSAGE_AMOUNT)
        deleteOldMessages(inMemoryStore);
    }

    function deleteOldMessages(inMemoryStore) {
      const allMessages = inMemoryStore.get('messages');
      onDel(
        allMessages
          .map((m) => m.id)
          .slice(0, allMessages.length - config.MAX_MESSAGE_AMOUNT),
        true
      );
    }

    function startSync() {
      return new Promise((resolve, reject) =>
        window.BackgroundFetch.start(resolve, reject)
      );
    }

    function stopSync() {
      return new Promise((resolve, reject) =>
        window.BackgroundFetch.stop(resolve, reject)
      );
    }

    return { init, addSyncListener, startSync, stopSync };
  }
  window.modules = window.modules || {};
  window.modules.BackgroundSynchronizer = BackgroundSynchronizer;
})();
