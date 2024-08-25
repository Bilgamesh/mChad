(function () {
  function AccountArticle({
    el,
    languages,
    profile,
    error,
    forum,
    isOpened,
    refreshTime,
    fetching,
    index,
    unreadMessages,
    timeUtil,
    documentUtil,
    Timer
  }) {
    let errorMessage;
    let successMessage;
    let currentlyOpenedText;
    let unreadMessagesText;
    let openText;
    let logoutActionText;
    let refreshingText;
    let secondsAgoMessage;

    const timer = Timer({ onTick });

    async function init() {
      errorMessage = await languages.getTranslation('REFRESH_FAILURE');
      successMessage = await languages.getTranslation('REFRESH_SUCCESS');
      currentlyOpenedText = await languages.getTranslation('CURRENTLY_OPENED');
      unreadMessagesText = await languages.getTranslation('UNREAD_MESSAGES');
      openText = await languages.getTranslation('OPEN');
      logoutActionText = await languages.getTranslation('LOGOUT_ACTION');
      refreshingText = await languages.getTranslation('REFRESHING_IN_PROGRESS');
    }

    async function getHtml() {
      return /* HTML */ `<article>
        <div class="row">
          <img class="circle large" src="${profile.avatarUrl}" />
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
            class="border open"
            index="${index}"
            ${isOpened ? 'disabled' : ''}
          >
            <i>menu_open</i><span>${openText}</span></button
          ><button class="border logout" index="${index}">
            <i>logout</i><span>${logoutActionText}</span>
          </button>
        </nav>
      </article>`;
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
      $('.username')[index].classList.remove('refresh-error');
      $('.refresh-icon')[index].classList.remove('refresh-error-dark');
      $('.refresh-icon')[index].classList.add('success');
      $('.forum-name')[index].classList.remove('refresh-error');
      $('.refresh-message')[index].classList.remove('refresh-error');
      $('.message-count')[index].classList.remove('refresh-error');
      $('.refresh-message')[index].innerText = refreshingText;
      if ($(`#loading-animation-${index}`)) return;
      const progressCircle = documentUtil.createHtmlElement({
        element: 'progress',
        className: 'circle small',
        id: `loading-animation-${index}`
      });
      $('.refresh-icon')[index].setAttribute('hide', 'true');
      $('.refresh-icon')[index].parentElement.insertBefore(
        progressCircle,
        $('.refresh-icon')[index]
      );
    }

    function endLoadingAnimation() {
      $(`#loading-animation-${index}`)?.remove();
      $('.refresh-icon')[index].setAttribute('hide', 'false');
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
      $('.username')[index].classList.add('refresh-error');
      $('.refresh-icon')[index].classList.add('refresh-error-dark');
      $('.refresh-icon')[index].classList.remove('success');
      $('.forum-name')[index].classList.add('refresh-error');
      $('.refresh-message')[index].classList.add('refresh-error');
      $('.message-count')[index].classList.add('refresh-error');
      $('.refresh-icon')[index].innerHTML = 'error';
    }

    function clearErrors() {
      $('.username')[index].classList.remove('refresh-error');
      $('.refresh-icon')[index].classList.remove('refresh-error-dark');
      $('.refresh-icon')[index].classList.add('success');
      $('.forum-name')[index].classList.remove('refresh-error');
      $('.refresh-message')[index].classList.remove('refresh-error');
      $('.message-count')[index].classList.remove('refresh-error');
      $('.refresh-icon')[index].innerHTML = 'check_circle';
    }

    async function onTick() {
      if ($(`#loading-animation-${index}`)) return;
      const newMessage = await timeUtil.timestampToTimeAgo(refreshTime);
      if (newMessage === secondsAgoMessage) return;
      secondsAgoMessage = newMessage;
      $('.refresh-message')[index].innerHTML = error
        ? `${errorMessage} ${secondsAgoMessage}`
        : `${successMessage} ${secondsAgoMessage}`;
    }

    function updateMessageCount(_unreadMessages) {
      unreadMessages = _unreadMessages;
      const count = unreadMessages.length;
      if (count == 0) {
        $('.message-count')[index].innerText = '';
        $('.message-count')[index].setAttribute('hide', 'true');
      } else {
        $('.message-count')[
          index
        ].innerText = `${unreadMessagesText}: ${count}`;
        $('.message-count')[index].setAttribute('hide', 'false');
      }
    }

    return {
      init,
      getHtml,
      updateStatus,
      updateMessageCount,
      startRefreshingCount,
      stopRefreshingCount
    };
  }
  window.modules = window.modules || {};
  window.modules.AccountArticle = AccountArticle;
})();