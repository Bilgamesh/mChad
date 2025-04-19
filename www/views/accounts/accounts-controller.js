import { PersistentStore } from '../../storage/persistent-store.js';
import { InMemoryStore } from '../../storage/in-memory-store.js';
import { DocumentUtil } from '../../utils/document.js';
import { Languages } from '../../languages/languages.js';
import { AccountsActions } from './scripts/accounts-actions.js';
import { AccountsUi } from './scripts/accounts-ui.js';

async function Accounts({
  el,
  config,
  globalSynchronizer,
  router,
  fetchTool,
  badges,
  popups
}) {
  const languages = Languages();
  const documentUtil = DocumentUtil();
  document.getElementById('body').setAttribute('page', 'accounts');

  const globalStorage = PersistentStore('*');

  const forums = globalStorage.get('forums') || [];

  const selectedForumIndex =
    documentUtil.getParam('forumIndex') ||
    globalStorage.get('currentForumIndex') ||
    config.DEFAULT_FORUM_INDEX;

  PersistentStore('*').set('currentForumIndex', selectedForumIndex);

  const ui = AccountsUi({
    el,
    selectedForumIndex,
    popups
  });

  const { profiles, errors, refreshTimes, fetchings, onlineUsersDatas } =
    await getAccountsData();

  const accountsActions = AccountsActions({
    accountsUi: ui,
    forums,
    fetchTool,
    globalSynchronizer,
    router,
    selectedForumIndex,
    profiles,
    badges,
    popups
  });

  const unreadMessagesData = getUnreadMessagesData();

  await ui.displayPage({
    forums,
    profiles,
    errors,
    refreshTimes,
    fetchings,
    unreadMessagesData,
    onlineUsersDatas
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
  const onlineUsersDataUpdateListenerIndex = globalSynchronizer.addSyncListener(
    'online-users-data-update',
    ui.updateOnlineUsersInfo
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
    const onlineUsersDatas = [];

    for (const forum of forums) {
      const forumStorage = PersistentStore(`${forum.address}_${forum.userId}`);
      const inMemoryStore = InMemoryStore(`${forum.address}_${forum.userId}`);
      const profile =
        forumStorage.get('profile') || (await createDummyProfile());
      const error = inMemoryStore.get('error');
      const refreshTime = forumStorage.get('refresh-time') || +new Date();
      const fetching = !!inMemoryStore.get('fetching');
      const onlineUsersData = forumStorage.get('online-users-data');
      profiles.push(profile);
      errors.push(error);
      refreshTimes.push(refreshTime);
      fetchings.push(fetching);
      onlineUsersDatas.push(onlineUsersData);
    }
    return { profiles, errors, refreshTimes, fetchings, onlineUsersDatas };
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
    globalSynchronizer.removeSyncListener(onlineUsersDataUpdateListenerIndex);
    globalSynchronizer.removeSyncListener(postSyncListenerIndex);
    document.removeEventListener('pause', ui.stopAllCounts);
    document.removeEventListener('resume', ui.startAllCounts);
    ui.stopAllCounts();
  }

  router.addOnDestroy(onDestroy);
}

export { Accounts };
