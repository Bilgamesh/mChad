(function () {
  function ToolsPanel({
    baseUrl,
    chatUiCache,
    inMemoryStore,
    forumStorage,
    popups,
    languages
  }) {
    const html =
      /* HTML */
      `<nav id="tools-panel" class="right-align" hide="true">
        <i id="reply-button" class="tool-item unhoverable">alternate_email</i>
        <i id="quote-button" class="tool-item unhoverable">format_quote</i>
        <i id="like-button" class="tool-item unhoverable">thumb_up</i>
        <i id="edit-button" class="tool-item unhoverable">edit</i>
        <i id="delete-button" class="tool-item unhoverable">delete</i>
        <i id="copy-button" class="tool-item unhoverable">content_copy</i>
      </nav>`;

    let messageDeleteListeners = [];
    let messageEditListeners = [];

    function addMessageDeleteListener(listen) {
      const id = crypto.randomUUID();
      messageDeleteListeners.push({ id, listen });
      return id;
    }

    function removeMessageDeleteListener(id) {
      messageDeleteListeners = messageDeleteListeners.filter(
        (listener) => listener.id !== id
      );
    }

    function addMessageEditListener(listen) {
      const id = crypto.randomUUID();
      messageEditListeners.push({ id, listen });
      return id;
    }

    function removeMessageEditListener(id) {
      messageEditListeners = messageEditListeners.filter(
        (listener) => listener.id !== id
      );
    }

    function getLikeMessage() {
      return inMemoryStore.get('likeMessage');
    }

    function registerListeners() {
      $('#reply-button').addEventListener('click', reply);
      $('#quote-button').addEventListener('click', quote);
      $('#like-button').addEventListener('click', like);
      $('#edit-button').addEventListener('click', edit);
      $('#delete-button').addEventListener('click', deleteMessage);
      $('#copy-button').addEventListener('click', copy);
    }

    function reply() {
      const userId = chatUiCache.lastSelected.getAttribute('user_id');
      const userName = chatUiCache.lastSelected.getAttribute('user_name');
      const replyMessage = `@[url=${baseUrl}/memberlist.php?mode=viewprofile&u=${userId}][b]${userName}[/b][/url]`;
      $('#input-box').value = $('#input-box').value.trim() + ' ' + replyMessage;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').focus();
    }

    function quote() {
      const userId = chatUiCache.lastSelected.getAttribute('user_id');
      const userName = chatUiCache.lastSelected.getAttribute('user_name');
      const postId = chatUiCache.lastSelected.getAttribute('id');
      const postTime = chatUiCache.lastSelected.getAttribute('time');
      const message = chatUiCache.lastSelected.getAttribute('message');
      const quoteMessage = `[quote="${userName}" post_id=${postId} time=${postTime} user_id=${userId}] ${message} [/quote]`;
      $('#input-box').value = $('#input-box').value.trim() + ' ' + quoteMessage;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').focus();
    }

    function like() {
      const userId = chatUiCache.lastSelected.getAttribute('user_id');
      const userName = chatUiCache.lastSelected.getAttribute('user_name');
      const postId = chatUiCache.lastSelected.getAttribute('id');
      const postTime = chatUiCache.lastSelected.getAttribute('time');
      const message = chatUiCache.lastSelected.getAttribute('message');
      const likeResponse = `[i]${getLikeMessage()}[/i][quote="${userName}" post_id=${postId} time=${postTime} user_id=${userId}] ${message} [/quote]`;
      $('#input-box').value = $('#input-box').value.trim() + ' ' + likeResponse;
      $('#input-box').value = $('#input-box').value.trim() + ' ';
      $('#input-box').focus();
    }

    async function edit() {
      const postId = chatUiCache.lastSelected.getAttribute('id');
      const oldText = chatUiCache.lastSelected.getAttribute('message');
      popups.showInputBox({
        title: await languages.getTranslation('EDIT_TITLE'),
        placeholder: chatUiCache.lastSelected.getAttribute('message'),
        focus: true,
        callback: (text) => {
          text = text.trim();
          if (oldText === text || text === '') return;
          for (const listener of messageEditListeners)
            listener.listen(postId, text);
        }
      });
    }

    async function deleteMessage() {
      const postId = chatUiCache.lastSelected.getAttribute('id');
      popups.showConfirmationBox({
        title: await languages.getTranslation('DELETE_TITLE'),
        text: await languages.getTranslation('DELETE_DESC'),
        onConfirm: () => {
          for (const listener of messageDeleteListeners)
            listener.listen(postId);
        }
      });
    }

    function copy() {
      const message = chatUiCache.lastSelected.getAttribute('message');
      navigator.clipboard.writeText(message);
    }

    function show(bubble) {
      const isSelf = bubble.classList.contains('right');
      const isEditable = isMessageEditable(bubble);
      $('#like-button')?.setAttribute('hide', `${isSelf}`);
      $('#reply-button')?.setAttribute('hide', `${isSelf}`);
      $('#edit-button')?.setAttribute('hide', `${!isSelf || !isEditable}`);
      $('#delete-button')?.setAttribute('hide', `${!isSelf || !isEditable}`);
      $('#tools-panel')?.setAttribute('hide', 'false');
    }

    function hide() {
      $('#tools-panel')?.setAttribute('hide', 'true');
    }

    function getHtml() {
      return html;
    }

    function isMessageEditable(bubble) {
      const editDeleteLimitSeconds =
        (forumStorage.get('editDeleteLimit') || 0) / 1000;
      const messageTimeSeconds = bubble.getAttribute('time');
      const nowSeconds = Math.floor(new Date().getTime() / 1000);
      const editDeleteTimeExpired =
        nowSeconds - messageTimeSeconds > editDeleteLimitSeconds;
      return !editDeleteTimeExpired;
    }

    return {
      getHtml,
      registerListeners,
      show,
      hide,
      addMessageDeleteListener,
      addMessageEditListener,
      removeMessageDeleteListener,
      removeMessageEditListener
    };
  }
  window.modules = window.modules || {};
  window.modules.ToolsPanel = ToolsPanel;
})();
