(function () {
  function MchatSingleSynchronizer({
    forum,
    cookieStore,
    forumIndex,
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
  }) {
    const forumStorage = PersistentStore(`${forum.address}_${forum.userId}`);
    const inMemoryStore = InMemoryStore(`${forum.address}_${forum.userId}`);
    const chatService = MchatChatService({
      baseUrl: forum.address,
      cookieStore,
      fetchTool,
      documentUtil
    });
    const onlineUsersService = MchatOnlineUsersService({
      baseUrl: forum.address,
      cookieStore,
      fetchTool,
      documentUtil
    });
    const userService = MchatUserService({
      baseUrl: forum.address,
      userId: forum.userId,
      cookieStore,
      fetchTool,
      documentUtil
    });
    const emoticonsService = MchatEmoticonsService({
      baseUrl: forum.address,
      cookieStore,
      fetchTool,
      documentUtil
    });
    const listeners = [];

    let index = 0;
    let stopped = false;
    const timer = Timer({ onTick });

    async function onTick() {
      try {
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] Start tick`
        );
        const existingMessages = inMemoryStore.get('messages') || [];

        /* When the application has just been opened
        (hence there are no remembered messages) 
        fetch the main page to get initial messages,
        formToken and creationTime */
        if (existingMessages.length === 0) {
          beforeRefresh();
          timer.pause();
          const {
            messages,
            bbtags,
            editDeleteLimit,
            cookie,
            formToken,
            creationTime
          } = await chatService.fetchMainPage();
          onRefresh();
          if (formToken) inMemoryStore.set('form-token', formToken);
          if (creationTime) inMemoryStore.set('creation-time', creationTime);
          if (cookie) await cookieStore.set(cookie); // Forum may return new cookies at any point
          for (const message of messages || []) message.read = true;
          if (messages) onAdd(messages);
          if (bbtags) setTimeout(() => onBBtags(bbtags), 500);
          onEditDeleteLimit(editDeleteLimit || 0);
          afterRefresh();
        }

        /* Check for new messages every tick
        after the initial messages have been fetched*/
        if (existingMessages.length > 0) {
          const latestMessage = existingMessages[existingMessages.length - 1];
          beforeRefresh();
          timer.pause();
          const { cookie, add, edit, del, log } = await chatService.refresh(
            latestMessage.id,
            inMemoryStore.get('logId')
          );
          onRefresh();
          if (cookie) await cookieStore.set(cookie);
          if (log) inMemoryStore.set('logId', log);
          if (add) onAdd(add);
          if (edit) onEdit(edit);
          if (del) onDel(del);
          afterRefresh();
        }

        /* When running application is resumed from background
        (hence sync was restarted so index is 0, but there are already
        remembered messagges from previous syncs)
        fetch the main page to refresh the formToken and creationTime
        needed for posting messages. Also do it if the appplication
        has been in the foreground for a long time (every 100th request) */
        if (
          (index === 0 && existingMessages.length > 0) ||
          (index % 100 === 0 && index !== 0)
        ) {
          timer.pause();
          const { cookie, bbtags, editDeleteLimit, formToken, creationTime } =
            await chatService.fetchMainPage();
          if (formToken) inMemoryStore.set('form-token', formToken);
          if (creationTime) inMemoryStore.set('creation-time', creationTime);
          if (cookie) await cookieStore.set(cookie);
          if (bbtags) onBBtags(bbtags);
          onEditDeleteLimit(editDeleteLimit || 0);
        }

        /* Periodically fetch user profile
        in case any user information has changed */
        if (index % 10 === 0) {
          const profile = await userService.fetchProfile();
          if (profile.cookie) cookieStore.set(profile.cookie);
          onProfileUpdate(profile);
        }

        /* Periodically check who is online */
        if (index % 10 === 0) {
          const {
            message,
            users,
            visibleCount,
            hiddenCount,
            totalCount,
            cookie
          } = await onlineUsersService.fetchUsers();
          if (cookie) await cookieStore.set(cookie);
          onOnlineUsersUpdate({
            message,
            users,
            visibleCount,
            hiddenCount,
            totalCount
          });
        }

        /* Periodically reload cached images */
        if (index % 10 === 0) documentUtil.reloadImages(forum.address);

        /* Periodically fetch emoticons
        in case forum admin has changed them */
        if (index % 15 === 0) {
          let next;
          let start = 0;
          let all = [];
          do {
            const { emoticons, hasHextPage, count, cookie } =
              await emoticonsService.fetchEmoticons(start);
            if (cookie) await cookieStore.set(cookie);
            all = [...all, ...emoticons];
            next = hasHextPage;
            start = count;
          } while (next);
          onNewEmoticons(all);
        }

        // All previous steps were successful
        inMemoryStore.del('error');
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] Error: ${err}`
        );
        onRefreshError(err);
      } finally {
        index++;
        timer.resume();
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] End tick`
        );
      }
    }

    function startSync() {
      timer.start({
        interval: config.SYNC_INTERVAL_MS,
        onSuccess: onTimerStartSuccess,
        onError: onTimerStartError
      });
    }

    function onTimerStartSuccess() {
      console.log(
        `[${new Date().toLocaleString()}][${forum.address}_${
          forum.userId
        }] Timer started`
      );
    }

    function onTimerStartError(errorMessage) {
      console.log(
        `[${new Date().toLocaleString()}][${forum.address}_${
          forum.userId
        }]Timer failed to start: ${errorMessage}`
      );
    }

    function stopSync() {
      timer.stop();
      stopped = true;
      console.log(
        `[${new Date().toLocaleString()}][${forum.address}_${
          forum.userId
        }] Timer stopped`
      );
    }

    function onBBtags(bbtags) {
      if (stopped) return;
      forumStorage.set('bbtags', bbtags);
      emit({ event: 'bbtags', baseUrl: forum.address, bbtags, forumIndex });
    }

    function onEditDeleteLimit(editDeleteLimit) {
      if (stopped) return;
      forumStorage.set('editDeleteLimit', editDeleteLimit);
      emit({
        event: 'editDeleteLimitUpdate',
        baseUrl: forum.address,
        forumIndex
      });
    }

    function onDel(ids, silent) {
      if (stopped) return;
      if (!Array.isArray(ids)) ids = [ids];
      const messages = inMemoryStore.get('messages');
      for (const id of ids) {
        const index = messages.findIndex((m) => m.id == id);
        if (index !== -1) inMemoryStore.del('messages', index);
        emit({
          event: 'delete',
          baseUrl: forum.address,
          id,
          forumIndex,
          silent
        });
      }
    }

    function onEdit(messages, self = false) {
      if (stopped) return;
      const existingMessages = inMemoryStore.get('messages') || [];
      if (!Array.isArray(messages)) messages = [messages];
      for (const message of messages) {
        const index = existingMessages.findIndex((m) => m.id == message.id);
        if (self && message.user.id === forum.userId) message.read = true;
        if (index !== -1) inMemoryStore.set('messages', message, index);
        emit({ event: 'edit', baseUrl: forum.address, message, forumIndex });
      }
    }

    function onAdd(messages) {
      if (stopped) return;
      if (!Array.isArray(messages)) messages = [messages];
      messages = messages.sort((a, b) => a.id - b.id);
      extractLikeMessage(messages);
      extractLogId(messages);
      for (const message of messages)
        if (!inMemoryStore.contains('messages', (m) => m.id == message.id))
          inMemoryStore.add('messages', message);
      emit({ event: 'add', baseUrl: forum.address, messages, forumIndex });
    }

    function onAddOld(messages, oldestMessageId) {
      if (!Array.isArray(messages)) messages = [messages];
      messages = messages.sort((a, b) => b.id - a.id);
      if (stopped) return;
      for (const message of messages)
        if (!inMemoryStore.contains('messages', (m) => m.id == message.id))
          inMemoryStore.unshift('messages', message);
      emit({
        event: 'addOld',
        baseUrl: forum.address,
        messages,
        forumIndex,
        oldestMessageId
      });
    }

    function onNewEmoticons(emoticons) {
      if (stopped) return;
      forumStorage.set('emoticons', emoticons);
      emit({
        event: 'new-emoticons',
        baseUrl: forum.address,
        forumIndex,
        emoticons
      });
    }

    function beforeRefresh() {
      emit({
        event: 'refresh-start',
        baseUrl: forum.address,
        userId: forum.userId,
        forumIndex
      });
      inMemoryStore.set('fetching', true);
    }

    function onRefresh() {
      if (stopped) return;
      inMemoryStore.del('error');
      inMemoryStore.del('fetching');
      forumStorage.set('refresh-time', +new Date());
      emit({
        event: 'refresh',
        baseUrl: forum.address,
        userId: forum.userId,
        forumIndex
      });
    }

    function afterRefresh() {
      if (stopped) return;
      emit({
        event: 'refresh-end',
        baseUrl: forum.address,
        userId: forum.userId,
        forumIndex
      });
    }

    function onProfileUpdate(profile) {
      if (stopped) return;
      forumStorage.set('profile', profile);
      emit({
        event: 'profileUpdate',
        baseUrl: forum.address,
        profile,
        forumIndex
      });
    }

    function onOnlineUsersUpdate(onlineUsersData) {
      if (stopped) return;
      forumStorage.set('online-users-data', onlineUsersData);
      emit({
        event: 'online-users-data-update',
        baseUrl: forum.address,
        forumIndex,
        ...onlineUsersData
      });
    }

    function onRefreshError(err) {
      if (stopped) return;
      inMemoryStore.del('fetching');
      inMemoryStore.set('error', err.toString());
      forumStorage.set('refresh-time', +new Date());
      (async () => {
        const errorMessage = await languages.getTranslation('SYNC_ERROR');
        popups.showError(`${errorMessage} ${forum.address}`);
      })();
      emit({
        event: 'syncError',
        type: 'refresh',
        baseUrl: forum.address,
        userId: forum.userId,
        error: err,
        forumIndex
      });
    }

    function onSubmitError(err, text) {
      if (stopped) return;
      inMemoryStore.del('fetching');
      inMemoryStore.set('error', err.toString());
      forumStorage.set('refresh-time', +new Date());
      (async () => {
        popups.showError(
          `${await languages.getTranslation(
            'MESSAGE_SUBMIT_ERROR_REASON'
          )}:\n${err}`
        );
      })();
      emit({
        event: 'syncError',
        type: 'submit',
        baseUrl: forum.address,
        userId: forum.userId,
        error: err,
        forumIndex,
        text
      });
    }

    function onDeleteError(err, id) {
      if (stopped) return;
      inMemoryStore.del('fetching');
      inMemoryStore.set('error', err.toString());
      forumStorage.set('refresh-time', +new Date());
      (async () => {
        popups.showError(
          `${await languages.getTranslation(
            'MESSAGE_DELETE_ERROR_REASON'
          )}:\n${err}`
        );
      })();
      emit({
        event: 'syncError',
        type: 'delete',
        baseUrl: forum.address,
        userId: forum.userId,
        error: err,
        forumIndex,
        id
      });
    }

    function onEditError(err, id, message) {
      if (stopped) return;
      inMemoryStore.del('fetching');
      inMemoryStore.set('error', err.toString());
      forumStorage.set('refresh-time', +new Date());
      (async () => {
        popups.showError(
          `${await languages.getTranslation(
            'MESSAGE_EDIT_ERROR_REASON'
          )}:\n${err}`
        );
      })();
      emit({
        event: 'syncError',
        type: 'edit',
        baseUrl: forum.address,
        userId: forum.userId,
        error: err,
        forumIndex,
        id,
        message
      });
    }

    async function sendToServer(text) {
      try {
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] Sending add request to server: ${text}`
        );
        const existingMessages = inMemoryStore.get('messages') || [];
        const latestMessage = existingMessages[existingMessages.length - 1];
        const last = latestMessage?.id || 0;
        const formToken = inMemoryStore.get('form-token');
        const creationTime = inMemoryStore.get('creation-time');
        beforeRefresh();
        const { cookie, add, edit, del } = await chatService.add({
          last,
          text,
          formToken,
          creationTime
        });
        onRefresh();
        if (cookie) await cookieStore.set(cookie);
        if (add) onAdd(add);
        if (edit) onEdit(edit);
        if (del) onDel(del);
        afterRefresh();
      } catch (err) {
        onSubmitError(err, text);
      }
    }

    async function deleteFromServer(id) {
      try {
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] Sending del request to server: ${id}`
        );
        const formToken = inMemoryStore.get('form-token');
        const creationTime = inMemoryStore.get('creation-time');
        beforeRefresh();
        const { cookie, add, edit, del } = await chatService.del({
          id,
          formToken,
          creationTime
        });
        onRefresh();
        if (cookie) await cookieStore.set(cookie);
        if (add) onAdd(add);
        if (edit) onEdit(edit);
        if (del) onDel(del);
        afterRefresh();
      } catch (err) {
        onDeleteError(err, id);
      }
    }

    async function editOnServer(id, message) {
      try {
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] Sending edit request to server: ${id} ${message}`
        );
        const formToken = inMemoryStore.get('form-token');
        const creationTime = inMemoryStore.get('creation-time');
        beforeRefresh();
        const { cookie, add, edit, del } = await chatService.edit({
          id,
          message,
          creationTime,
          formToken
        });
        onRefresh();
        if (cookie) await cookieStore.set(cookie);
        if (add) onAdd(add);
        if (edit) onEdit(edit, true);
        if (del) onDel(del);
        afterRefresh();
      } catch (err) {
        onEditError(err, id, message);
      }
    }

    async function getArchiveMessages(startIndex = 0, oldestMessageId) {
      try {
        console.log(
          `[${new Date().toLocaleString()}][${forum.address}_${
            forum.userId
          }] Requesting archive at index: ${startIndex}`
        );
        emit({
          event: 'archiveStart',
          baseUrl: forum.address,
          forumIndex
        });
        const { messages, cookie } = await chatService.fetchArchive(startIndex);
        if (cookie) await cookieStore.set(cookie);
        if (messages) onAddOld(messages, oldestMessageId);
        emit({
          event: 'archiveEnd',
          baseUrl: forum.address,
          forumIndex,
          messages
        });
        return messages || null;
      } catch (err) {
        popups.showError(
          `${await languages.getTranslation('ARCHIVE_LOAD_ERROR')}:\n${err}`
        );
        emit({
          event: 'archiveEnd',
          baseUrl: forum.address,
          forumIndex,
          error: err
        });
      }
    }

    function extractLikeMessage(messages) {
      if (messages.length && messages[0].likeMessage) {
        const likeMessage = documentUtil.unicodeToString(
          messages[0].likeMessage
        );
        inMemoryStore.set('likeMessage', likeMessage);
      }
    }

    function extractLogId(messages) {
      if (messages.length && messages[0].logId)
        inMemoryStore.set('logId', messages[0].logId);
    }

    function emit(event) {
      if (stopped) return;
      console.log(
        `[${new Date().toLocaleString()}][${forum.address}_${
          forum.userId
        }] Emitting: ${event.event}`
      );
      for (const listener of listeners)
        try {
          listener.listen(event);
        } catch (err) {
          console.log(
            `[${new Date().toLocaleString()}][${forum.address}_${
              forum.userId
            }] Error in one of event (${JSON.stringify({
              event
            })}) listeners: ${err}`
          );
        }
    }

    function addSyncListener(event, listen) {
      if (event === '*') listeners.push({ listen });
      else
        listeners.push({
          listen: (o) => {
            if (o.event === event) listen(o);
          }
        });
      return listeners.length - 1;
    }

    function removeSyncListener(index) {
      listeners.splice(index, 1);
    }

    return {
      startSync,
      stopSync,
      addSyncListener,
      removeSyncListener,
      sendToServer,
      deleteFromServer,
      editOnServer,
      getArchiveMessages
    };
  }

  window.modules = window.modules || {};
  window.modules.MchatSingleSynchronizer = MchatSingleSynchronizer;
})();
