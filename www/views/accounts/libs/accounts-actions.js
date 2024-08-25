(function () {
  function AccountsActions({
    accountsUi,
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
  }) {
    const globalStorage = PersistentStore('*');

    async function updateSelection(newIndex) {
      selectedForumIndex = newIndex;
      if (!forums[newIndex]) return;
      globalStorage.set('currentForumIndex', newIndex);
      accountsUi.enableOpenButtons();
      await accountsUi.clearForumTitles();
      accountsUi.disableOpenButton(newIndex);
      await accountsUi.markForumAsOpened(newIndex);
      accountsUi.updateTitleBar(
        forums[newIndex].name || forums[newIndex].address
      );
    }

    async function signOutOfForum(index) {
      const { address, userId } = forums[index];
      const cookieStore = CookieStore(`${address}_${userId}`, PersistentStore);
      try {
        const mchatMchatLoginService = MchatLoginService({
          baseUrl: address,
          urlUtil,
          fetchTool,
          documentUtil
        });
        await mchatMchatLoginService.init();
        await mchatMchatLoginService.logout(cookieStore);
      } catch (err) {
        popups.showError(await languages.getTranslation('LOGOUT_ERROR'));
      }
    }

    function cleanupForumData(index) {
      const { address, userId } = forums[index];
      const cookieStore = CookieStore(`${address}_${userId}`, PersistentStore);
      cookieStore.del();
      PersistentStore(`${address}_${userId}`).clear();
      InMemoryStore(`${address}_${userId}`).clear();
      badges.updateUnreadMessagesList();
      globalStorage.del('forums', index);
      forums.splice(index, 1);
    }

    async function confirmLogout() {
      const index = [...$('.logout')].indexOf(this);
      const profile = profiles[index];
      const forum = forums[index];
      popups.showConfirmationBox({
        title: await languages.getTranslation('LOGOUT'),
        text: (await languages.getTranslation('LOGOUT_CONFIRMATION')).replace(
          '{{ACCOUNT}}',
          `${profile.username}@${forum.name}`
        ),
        onConfirm: async () => {
          await logout(index);
        }
      });
    }

    async function updateArticlesMessageCount() {
      for (let i = 0; i < forums.length; i++) {
        const unreadMessages = badges.getForumSpecificUnreadMessages(i);
        await accountsUi.updateUnreadMessagesParagraph(i, unreadMessages);
      }
    }

    async function logout(index) {
      accountsUi.appendLogoutProgressCircle(index);
      accountsUi.disableLogoutButtons();
      await signOutOfForum(index);
      cleanupForumData(index);
      badges.refreshBadges();
      globalSynchronizer.restartSync();
      accountsUi.removeAccountArticle(index);
      if (!forums.length) router.redirect('#login');
      if (selectedForumIndex > index)
        await updateSelection(selectedForumIndex - 1);
      if (selectedForumIndex == index) {
        await updateSelection(0);
      }
      accountsUi.enableLogoutButtons();
    }

    return {
      updateSelection,
      updateArticlesMessageCount,
      signOutOfForum,
      cleanupForumData,
      confirmLogout,
      logout
    };
  }
  window.modules = window.modules || {};
  window.modules.AccountsActions = AccountsActions;
})();
