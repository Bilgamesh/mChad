import { Languages } from '../../../languages/languages.js';
import { DocumentUtil } from '../../../utils/document.js';
import { HapticsUtil } from '../../../utils/haptics.js';
import { sleep } from '../../../utils/sleep.js';
import { AccountArticle } from './account-article.js';

function AccountsUi({
  el,
  selectedForumIndex,
  popups
}) {
  const languages = Languages();
  const hapticsUtil = HapticsUtil();
  const documentUtil = DocumentUtil();
  let articles = [];

  function init() {
    registerHaptics();
  }

  function registerHaptics() {
    document
      .getElementById('new-account-button')
      .addEventListener('click', hapticsUtil.tapDefault);
    for (const openButton of document.getElementsByClassName('open'))
      openButton.addEventListener('click', hapticsUtil.tapDefault);
    for (const logoutButton of document.getElementsByClassName('logout'))
      logoutButton.addEventListener('click', hapticsUtil.tapDefault);
  }

  async function displayPage({
    forums,
    profiles,
    errors,
    refreshTimes,
    fetchings,
    unreadMessagesData,
    onlineUsersDatas
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
              unreadMessagesData,
              onlineUsersDatas
            )}
          </center>
        </div>
        <br /><br /><br /><br /><br /><br />

        <button
          id="new-account-button"
          class="extend circle left-round top-round extra fill active page ripple"
        >
          <i>login</i>
          <span>${await languages.getTranslation('LOGIN')}</span>
        </button>
      </div>
    `;

    addListeners();
    startAllCounts();
  }

  async function buildAccountArticlesHtml(
    forums,
    profiles,
    errors,
    refreshTimes,
    fetchings,
    unreadMessagesData,
    onlineUsersDatas
  ) {
    let articlesHtml = '';
    for (const [index, forum] of forums.entries()) {
      const isOpened = selectedForumIndex == index;
      const profile = profiles[index];
      const error = errors[index];
      const refreshTime = refreshTimes[index];
      const fetching = fetchings[index];
      const unreadMessages = unreadMessagesData[index];
      const onlineUsersData = onlineUsersDatas[index];
      const article = AccountArticle({
        profile,
        error,
        forum,
        isOpened,
        refreshTime,
        fetching,
        unreadMessages,
        onlineUsersData,
        index,
        popups
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
    document
      .getElementById('new-account-button')
      .addEventListener('click', listen);
  }

  function addOpenButtonsListener(listen) {
    for (const openButton of document.getElementsByClassName('open'))
      openButton.addEventListener('click', listen);
  }

  function addLogoutButtonsListener(listen) {
    for (const logoutButton of document.getElementsByClassName('logout')) {
      logoutButton.addEventListener('click', listen);
    }
  }

  function disableLogoutButtons() {
    for (const button of document.getElementsByClassName('logout'))
      button.disabled = true;
  }

  function enableLogoutButtons() {
    for (const button of document.getElementsByClassName('logout'))
      button.disabled = false;
  }

  function enableOpenButtons() {
    for (const openButton of document.getElementsByClassName('open'))
      openButton.disabled = false;
  }

  function disableOpenButton(index) {
    if (document.getElementsByClassName('open')[index])
      document.getElementsByClassName('open')[index].disabled = true;
  }

  async function markForumAsOpened(index) {
    if (!document.getElementsByClassName('forum-name')[index]) return;
    document.getElementsByClassName('forum-name')[index].innerText =
      document.getElementsByClassName('forum-name')[index].innerText +
      ' - ' +
      (await languages.getTranslation('CURRENTLY_OPENED'));
  }

  async function clearForumTitles() {
    for (const forumName of document.getElementsByClassName('forum-name'))
      forumName.innerText = forumName.innerText.replace(
        ' - ' + (await languages.getTranslation('CURRENTLY_OPENED')),
        ''
      );
  }

  function updateTitleBar(title) {
    document.querySelectorAll('#navbar-top-title').innerText = title;
  }

  function appendLogoutProgressCircle(index) {
    document
      .querySelectorAll('.logout')
      [index].appendChild(
        documentUtil.createElementFromHTML(/* HTML */ `<progress
          class="circle small"
        ></progress>`)
      );
  }

  async function updateUnreadMessagesParagraph(index, unreadMessages) {
    const article = articles[index];
    article.updateMessageCount(unreadMessages);
  }

  function removeAccountArticle(index) {
    const article = articles[index];
    article.stopRefreshingCount();
    articles = articles.filter((v, i) => i != index);
    document.getElementById('center').children[index].remove();
  }

  function startAllCounts() {
    for (const article of articles) article.startRefreshingCount();
  }

  function stopAllCounts() {
    for (const article of articles) article.stopRefreshingCount();
  }

  function updateOnlineUsersInfo(data) {
    for (const article of articles) article.updateOnlineUsersInfo(data);
  }

  function addListeners() {
    for (const article of articles) article.addListeners();
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
    updateOnlineUsersInfo,
    removeAccountArticle,
    updateUnreadMessagesParagraph,
    startAllCounts,
    stopAllCounts
  };
}

export { AccountsUi };
