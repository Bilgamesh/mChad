(function () {
  function ToolsPanel({
    baseUrl,
    chatUiCache,
    inMemoryStore,
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
      popups.showInputBox({
        title: await languages.getTranslation('EDIT_TITLE'),
        placeholder: chatUiCache.lastSelected.getAttribute('message'),
        callback: console.log
      });
    }

    async function deleteMessage() {
      popups.showConfirmationBox({
        title: await languages.getTranslation('DELETE_TITLE'),
        text: await languages.getTranslation('DELETE_DESC'),
        onConfirm: async () => {}
      });
    }

    function copy() {
      const message = chatUiCache.lastSelected.getAttribute('message');
      navigator.clipboard.writeText(message);
    }

    function show(isSelf) {
      $('#like-button')?.setAttribute('hide', `${isSelf}`);
      $('#reply-button')?.setAttribute('hide', `${isSelf}`);
      $('#edit-button')?.setAttribute('hide', `${!isSelf}`);
      $('#delete-button')?.setAttribute('hide', `${!isSelf}`);
      $('#tools-panel')?.setAttribute('hide', 'false');
    }

    function hide() {
      $('#tools-panel')?.setAttribute('hide', 'true');
    }

    function getHtml() {
      return html;
    }

    return { getHtml, registerListeners, show, hide };
  }
  window.modules = window.modules || {};
  window.modules.ToolsPanel = ToolsPanel;
})();
