import { Languages } from '../../../languages/languages.js';
import { DocumentUtil } from '../../../utils/document.js';
import { HapticsUtil } from '../../../utils/haptics.js';
import { TimeUtil } from '../../../utils/time.js';
import { Timer } from '../../../utils/timer.js';

function AccountArticle({
  profile,
  error,
  forum,
  isOpened,
  refreshTime,
  fetching,
  onlineUsersData,
  index,
  unreadMessages,
  popups
}) {
  const languages = Languages();
  const hapticsUtil = HapticsUtil();
  const documentUtil = DocumentUtil();
  const timeUtil = TimeUtil();
  let errorMessage;
  let successMessage;
  let currentlyOpenedText;
  let unreadMessagesText;
  let openText;
  let logoutActionText;
  let refreshingText;
  let secondsAgoMessage;
  let usersOnlineText;
  let loggedInUsersText;
  let hiddenUsersText;
  const timer = Timer({ onTick });

  async function init() {
    errorMessage = await languages.getTranslation('REFRESH_FAILURE');
    successMessage = await languages.getTranslation('REFRESH_SUCCESS');
    currentlyOpenedText = await languages.getTranslation('CURRENTLY_OPENED');
    unreadMessagesText = await languages.getTranslation('UNREAD_MESSAGES');
    openText = await languages.getTranslation('OPEN');
    logoutActionText = await languages.getTranslation('LOGOUT_ACTION');
    refreshingText = await languages.getTranslation('REFRESHING_IN_PROGRESS');
    usersOnlineText = await languages.getTranslation('USERS_ONLINE');
    loggedInUsersText = await languages.getTranslation('USERS');
    hiddenUsersText = await languages.getTranslation('HIDDEN_USERS');
  }

  async function getHtml() {
    return /* HTML */ `<article>
      <div class="row">
        <div
          class="circle large avatar"
          style="background-image: url(${profile.avatarUrl})"
        ></div>
        <div class="max">
          <h5
            class="${error && !fetching
              ? 'refresh-error username'
              : 'username'}"
          >
            <span>${profile.username} </span>
            ${fetching
              ? `<progress id="loading-animation-${index}" class="circle small"></progress>`
              : ''}
            <i
              class="${error
                ? 'refresh-error-dark refresh-icon'
                : 'success refresh-icon'}"
              hide="${fetching}"
              >${error ? 'error' : 'check_circle'}</i
            >
          </h5>
          <p
            class="${error && !fetching
              ? 'refresh-error forum-name'
              : 'forum-name'}"
          >
            @${(forum.name || forum.address) +
            (isOpened ? ' - ' + currentlyOpenedText : '')}
          </p>
          <p
            class="${error && !fetching
              ? 'refresh-error user-count-info'
              : 'user-count-info'}"
          >
            <span id="user-count-info-${index}"
              >${usersOnlineText} ${onlineUsersData.totalCount}</span
            >
            <i id="info-icon-${index}" class="info">info</i>
          </p>
          <p
            class="${error && !fetching
              ? 'refresh-error refresh-message'
              : 'refresh-message'}"
          >
            ${fetching
              ? refreshingText
              : error
              ? `${errorMessage} ${await timeUtil.timestampToTimeAgo(
                  refreshTime
                )}`
              : `${successMessage} ${await timeUtil.timestampToTimeAgo(
                  refreshTime
                )}`}
          </p>
          <p
            class="${error ? 'refresh-error message-count' : 'message-count'}"
            hide="${unreadMessages.length ? 'false' : 'true'}"
          >
            ${unreadMessages.length
              ? `${unreadMessagesText}: ${unreadMessages.length}`
              : ''}
          </p>
        </div>
      </div>
      <nav class="right-align">
        <button
          class="border open ripple"
          index="${index}"
          ${isOpened ? 'disabled' : ''}
        >
          <i>menu_open</i><span>${openText}</span></button
        ><button class="border logout ripple" index="${index}">
          <i>logout</i><span>${logoutActionText}</span>
        </button>
      </nav>
    </article>`;
  }

  function addListeners() {
    document
      .getElementById(`info-icon-${index}`)
      .addEventListener('click', hapticsUtil.tapDefault);
    document
      .getElementById(`info-icon-${index}`)
      .addEventListener('click', displayOnlineUsersModal);
  }

  function startRefreshingCount() {
    secondsAgoMessage = '';
    timer.start({
      interval: 100
    });
  }

  function stopRefreshingCount() {
    timer.pause();
  }

  function showRefreshStatus() {
    document
      .querySelectorAll('.username')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.refresh-icon')
      [index].classList.remove('refresh-error-dark');
    document.getElementsByClassName('refresh-icon')[index].classList.add('success');
    document
      .querySelectorAll('.forum-name')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.refresh-message')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.message-count')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.user-count-info')
      [index].classList.remove('refresh-error');
    document.getElementsByClassName('refresh-message')[index].innerText =
      refreshingText;
    if (document.getElementById(`loading-animation-${index}`)) return;
    document
      .querySelectorAll('.refresh-icon')
      [index].setAttribute('hide', 'true');
    document
      .querySelectorAll('.refresh-icon')
      [index].parentElement.insertBefore(
        documentUtil.createElementFromHTML(/* HTML */ `<progress
          id="loading-animation-${index}"
          class="circle small"
        ></progress>`),
        document.getElementsByClassName('refresh-icon')[index]
      );
  }

  function endLoadingAnimation() {
    document.getElementById(`loading-animation-${index}`)?.remove();
    document
      .querySelectorAll('.refresh-icon')
      [index].setAttribute('hide', 'false');
  }

  async function updateStatus({ error: _error, event }) {
    error = _error;
    switch (event) {
      case 'refresh-start':
        stopRefreshingCount();
        showRefreshStatus();
        break;
      case 'refresh-end':
        refreshTime = new Date().getTime();
        endLoadingAnimation();
        clearErrors();
        startRefreshingCount();
        break;
      case 'syncError':
        refreshTime = new Date().getTime();
        endLoadingAnimation();
        showError();
        startRefreshingCount();
        break;
      default:
        break;
    }
  }

  function showError() {
    document
      .querySelectorAll('.username')
      [index].classList.add('refresh-error');
    document
      .querySelectorAll('.refresh-icon')
      [index].classList.add('refresh-error-dark');
    document
      .querySelectorAll('.refresh-icon')
      [index].classList.remove('success');
    document
      .querySelectorAll('.forum-name')
      [index].classList.add('refresh-error');
    document
      .querySelectorAll('.refresh-message')
      [index].classList.add('refresh-error');
    document
      .querySelectorAll('.message-count')
      [index].classList.add('refresh-error');
    document
      .querySelectorAll('.user-count-info')
      [index].classList.add('refresh-error');
    document.getElementsByClassName('refresh-icon')[index].innerHTML = 'error';
  }

  function clearErrors() {
    document
      .querySelectorAll('.username')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.refresh-icon')
      [index].classList.remove('refresh-error-dark');
    document.getElementsByClassName('refresh-icon')[index].classList.add('success');
    document
      .querySelectorAll('.forum-name')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.refresh-message')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.message-count')
      [index].classList.remove('refresh-error');
    document
      .querySelectorAll('.user-count-info')
      [index].classList.remove('refresh-error');
    document.getElementsByClassName('refresh-icon')[index].innerHTML =
      'check_circle';
  }

  async function onTick() {
    if (document.getElementById(`loading-animation-${index}`)) return;
    const newMessage = await timeUtil.timestampToTimeAgo(refreshTime);
    if (newMessage === secondsAgoMessage) return;
    secondsAgoMessage = newMessage;
    document.getElementsByClassName('refresh-message')[index].innerHTML = error
      ? `${errorMessage} ${secondsAgoMessage}`
      : `${successMessage} ${secondsAgoMessage}`;
  }

  function updateMessageCount(_unreadMessages) {
    unreadMessages = _unreadMessages;
    const count = unreadMessages.length;
    if (count == 0) {
      document.getElementsByClassName('message-count')[index].innerText = '';
      document
        .querySelectorAll('.message-count')
        [index].setAttribute('hide', 'true');
    } else {
      document.getElementsByClassName('message-count')[
        index
      ].innerText = `${unreadMessagesText}: ${count}`;
      document
        .querySelectorAll('.message-count')
        [index].setAttribute('hide', 'false');
    }
  }

  function updateOnlineUsersInfo({
    forumIndex,
    message,
    users,
    visibleCount,
    hiddenCount,
    totalCount
  }) {
    if (index != forumIndex) return;
    onlineUsersData.message = message;
    onlineUsersData.users = users;
    onlineUsersData.visibleCount = visibleCount;
    onlineUsersData.hiddenCount = hiddenCount;
    onlineUsersData.totalCount = totalCount;
    document.getElementById(`user-count-info-${index}`).innerHTML =
      usersOnlineText + ' ' + totalCount;
  }

  function displayOnlineUsersModal() {
    const { users, hiddenCount } = onlineUsersData;
    let content = '';
    for (const user of users) content += `<p>${user.username}</p>`;
    if (hiddenCount > 0) content += `<p>${hiddenUsersText} ${hiddenCount}</p>`;
    popups.showInfoBox({
      title: loggedInUsersText,
      content
    });
  }

  return {
    init,
    getHtml,
    addListeners,
    updateStatus,
    updateMessageCount,
    startRefreshingCount,
    stopRefreshingCount,
    updateOnlineUsersInfo
  };
}

export { AccountArticle };
