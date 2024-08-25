(function () {
  function AccountsUi({
    el,
    hapticsUtil,
    languages,
    selectedForumIndex,
    AccountArticle,
    sleep,
    documentUtil,
    timeUtil,
    Timer
  }) {
    let articles = [];

    function init() {
      registerHaptics();
    }

    function registerHaptics() {
      $('#new-account-button').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      for (const openButton of $('.open'))
        openButton.addEventListener('click', hapticsUtil.tapDefault);
      for (const logoutButton of $('.logout'))
        logoutButton.addEventListener('click', hapticsUtil.tapDefault);
    }

    async function displayPage({
      forums,
      profiles,
      errors,
      refreshTimes,
      fetchings,
      unreadMessagesData
    }) {
      /* Emptying the page just before re-rendering
      and giving browser an overhead via dummy timeout
      makes BeerCSS transition animations much smoother */
      while (el.firstChild) el.removeChild(el.firstChild);
      await sleep(0);

      el.innerHTML = /* HTML */ `
        <div class="bg">
          <div class="page active">
            <center id="center">
              ${await buildAccountArticlesHtml(
                forums,
                profiles,
                errors,
                refreshTimes,
                fetchings,
                unreadMessagesData
              )}
            </center>
          </div>
          <br /><br /><br /><br /><br /><br />

          <button
            id="new-account-button"
            class="extend circle left-round top-round extra fill active page"
          >
            <i>login</i>
            <span>${await languages.getTranslation('LOGIN')}</span>
          </button>
        </div>
      `;

      startAllCounts();
    }

    async function buildAccountArticlesHtml(
      forums,
      profiles,
      errors,
      refreshTimes,
      fetchings,
      unreadMessagesData
    ) {
      let articlesHtml = '';
      for (const [index, forum] of forums.entries()) {
        const isOpened = selectedForumIndex == index;
        const profile = profiles[index];
        const error = errors[index];
        const refreshTime = refreshTimes[index];
        const fetching = fetchings[index];
        const unreadMessages = unreadMessagesData[index];
        const article = AccountArticle({
          languages,
          profile,
          error,
          forum,
          isOpened,
          refreshTime,
          fetching,
          unreadMessages,
          index,
          timeUtil,
          documentUtil,
          Timer
        });
        await article.init();
        articlesHtml += await article.getHtml();
        articles[index] = article;
      }
      return articlesHtml;
    }

    async function updateAccountArticleStatus({ forumIndex, error, event }) {
      const article = articles[forumIndex];
      await article.updateStatus({ error, event });
    }

    function addNewAccountButtonListener(listen) {
      $('#new-account-button').addEventListener('click', listen);
    }

    function addOpenButtonsListener(listen) {
      for (const openButton of $('.open'))
        openButton.addEventListener('click', listen);
    }

    function addLogoutButtonsListener(listen) {
      for (const logoutButton of $('.logout')) {
        logoutButton.addEventListener('click', listen);
      }
    }

    function disableLogoutButtons() {
      for (const button of $('.logout')) button.disabled = true;
    }

    function enableLogoutButtons() {
      for (const button of $('.logout')) button.disabled = false;
    }

    function enableOpenButtons() {
      for (const openButton of $('.open')) openButton.disabled = false;
    }

    function disableOpenButton(index) {
      if ($('.open')[index]) $('.open')[index].disabled = true;
    }

    async function markForumAsOpened(index) {
      if (!$('.forum-name')[index]) return;
      $('.forum-name')[index].innerText =
        $('.forum-name')[index].innerText +
        ' - ' +
        (await languages.getTranslation('CURRENTLY_OPENED'));
    }

    async function clearForumTitles() {
      for (const forumName of $('.forum-name'))
        forumName.innerText = forumName.innerText.replace(
          ' - ' + (await languages.getTranslation('CURRENTLY_OPENED')),
          ''
        );
    }

    function updateTitleBar(title) {
      $('#navbar-top-title').innerText = title;
    }

    function appendLogoutProgressCircle(index) {
      const progressCircle = documentUtil.createHtmlElement({
        element: 'progress',
        className: 'circle small'
      });
      $('.logout')[index].appendChild(progressCircle);
    }

    async function updateUnreadMessagesParagraph(index, unreadMessages) {
      const article = articles[index];
      article.updateMessageCount(unreadMessages);
    }

    function removeAccountArticle(index) {
      const article = articles[index];
      article.stopRefreshingCount();
      articles = articles.filter((v, i) => i != index);
      $('#center').children[index].remove();
    }

    function startAllCounts() {
      for (const article of articles) article.startRefreshingCount();
    }

    function stopAllCounts() {
      for (const article of articles) article.stopRefreshingCount();
    }

    return {
      init,
      displayPage,
      buildAccountArticlesHtml,
      updateAccountArticleStatus,
      addNewAccountButtonListener,
      addOpenButtonsListener,
      addLogoutButtonsListener,
      disableLogoutButtons,
      enableLogoutButtons,
      enableOpenButtons,
      disableOpenButton,
      markForumAsOpened,
      clearForumTitles,
      updateTitleBar,
      appendLogoutProgressCircle,
      removeAccountArticle,
      updateUnreadMessagesParagraph,
      startAllCounts,
      stopAllCounts
    };
  }

  window.modules = window.modules || {};
  window.modules.AccountsUi = AccountsUi;
})();
