(function () {
  async function Accounts({
    el,
    languages,
    PersistentStore,
    globalSynchronizer,
    documentUtil,
    router,
    hapticsUtil,
    InMemoryStore,
    sleep,
    AccountsUi,
    MchatLoginService,
    urlUtil,
    fetchTool,
    config,
    CookieStore,
    AccountArticle,
    AccountsActions,
    badges,
    popups,
    timeUtil,
    Timer
  }) {
    $('#body').setAttribute('page', 'accounts');

    const globalStorage = PersistentStore('*');

    const forums = globalStorage.get('forums') || [];

    const selectedForumIndex =
      documentUtil.getParam('forumIndex') ||
      globalStorage.get('currentForumIndex') ||
      config.DEFAULT_FORUM_INDEX;

    PersistentStore('*').set('currentForumIndex', selectedForumIndex);

    const ui = AccountsUi({
      el,
      hapticsUtil,
      languages,
      selectedForumIndex,
      AccountArticle,
      sleep,
      documentUtil,
      timeUtil,
      Timer
    });

    const { profiles, errors, refreshTimes, fetchings } = await getAccountsData();

    const accountsActions = AccountsActions({
      accountsUi: ui,
      PersistentStore,
      forums,
      MchatLoginService,
      urlUtil,
      fetchTool,
      CookieStore,
      InMemoryStore,
      globalSynchronizer,
      router,
      selectedForumIndex,
      profiles,
      languages,
      badges,
      popups,
      documentUtil
    });

    const unreadMessagesData = getUnreadMessagesData();

    await ui.displayPage({
      forums,
      profiles,
      errors,
      refreshTimes,
      fetchings,
      unreadMessagesData
    });

    ui.init();

    ui.addNewAccountButtonListener(() =>
      router.redirect(
        `#login?forumIndex=${forums.length}&_t=${new Date().getTime()}`
      )
    );

    ui.addOpenButtonsListener(function () {
      router.redirect(`#chat?forumIndex=${this.getAttribute('index')}`);
    });

    ui.addLogoutButtonsListener(accountsActions.confirmLogout);

    const presyncListenerIndex = globalSynchronizer.addSyncListener(
      'refresh-start',
      ui.updateAccountArticleStatus
    );
    const syncListenerIndex = globalSynchronizer.addSyncListener(
      'refresh-end',
      ui.updateAccountArticleStatus
    );
    const errorListenerIndex = globalSynchronizer.addSyncListener(
      'syncError',
      ui.updateAccountArticleStatus
    );
    const postSyncListenerIndex = globalSynchronizer.addSyncListener(
      'refresh-end',
      accountsActions.updateArticlesMessageCount
    );
    document.addEventListener('pause', ui.stopAllCounts);
    document.addEventListener('resume', ui.startAllCounts);

    function getUnreadMessagesData() {
      const unreadMessagesData = [];
      for (let i = 0; i < forums.length; i++)
        unreadMessagesData[i] = badges.getForumSpecificUnreadMessages(i);
      return unreadMessagesData;
    }

    async function getAccountsData() {
      const profiles = [];
      const errors = [];
      const refreshTimes = [];
      const fetchings = [];

      for (const forum of forums) {
        const forumStorage = PersistentStore(
          `${forum.address}_${forum.userId}`
        );
        const inMemoryStore = InMemoryStore(`${forum.address}_${forum.userId}`);
        const profile =
          forumStorage.get('profile') || (await createDummyProfile());
        const error = inMemoryStore.get('error');
        const refreshTime = forumStorage.get('refresh-time') || +new Date();
        const fetching = !!inMemoryStore.get('fetching');
        console.log({ fetching });
        profiles.push(profile);
        errors.push(error);
        refreshTimes.push(refreshTime);
        fetchings.push(fetching);
      }
      return { profiles, errors, refreshTimes, fetchings };
    }

    async function createDummyProfile() {
      return {
        avatarUrl: './img/no_avatar.gif',
        username: await languages.getTranslation('UNKNOWN')
      };
    }

    function onDestroy() {
      globalSynchronizer.removeSyncListener(presyncListenerIndex);
      globalSynchronizer.removeSyncListener(syncListenerIndex);
      globalSynchronizer.removeSyncListener(errorListenerIndex);
      globalSynchronizer.removeSyncListener(postSyncListenerIndex);
      document.removeEventListener('pause', ui.stopAllCounts);
      document.removeEventListener('resume', ui.startAllCounts);
      ui.stopAllCounts();
    }

    router.addOnDestroy(onDestroy);
  }
  window.modules = window.modules || {};
  window.modules.Accounts = Accounts;
})();
