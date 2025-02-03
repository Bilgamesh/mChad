(function () {
  async function Navbar({ languages, hapticsUtil, documentUtil }) {
    let router;

    const html = /* HTML */ `<nav class="bottom" id="navbar-bottom">
      <a class="active inactive" href="/#chat" id="chat-btn" draggable="false">
        <i class="nav-icon" href="/#chat">chat</i>
        <div href="/#chat" translation="CHAT">
          ${await languages.getTranslation('CHAT')}
        </div>
      </a>
      <a
        class="active inactive"
        href="/#accounts"
        id="accounts-btn"
        draggable="false"
      >
        <i class="nav-icon" href="/#accounts">group</i>
        <div href="/#accounts" translation="ACCOUNTS">
          ${await languages.getTranslation('ACCOUNTS')}
        </div>
      </a>
      <a
        class="active inactive"
        href="/#settings"
        id="settings-btn"
        draggable="false"
      >
        <i class="nav-icon" href="/#settings">settings</i>
        <div href="/#settings" translation="SETTINGS">
          ${await languages.getTranslation('SETTINGS')}
        </div>
      </a>
    </nav>`;

    function getHtml() {
      return html;
    }

    function updateSelection() {
      const [hash] = location.hash.split('?');
      const { elementId } = router.ROUTES[hash] || {};
      for (const button of $('#navbar-bottom').children) {
        if (button.id === elementId) select(button);
        else deselect(button);
      }
    }

    function select(element) {
      element.classList.add('active');
      element.classList.remove('inactive');
    }

    function deselect(element) {
      element.classList.remove('active');
      element.classList.add('inactive');
    }

    function show() {
      $('#navbar-bottom').style.display = '';
    }

    function hide() {
      $('#navbar-bottom').style.display = 'none';
    }

    function registerRoutes() {
      for (const key in router.ROUTES)
        if (
          Object.hasOwnProperty.call(router.ROUTES, key) &&
          router.ROUTES[key].elementId
        ) {
          const { elementId } = router.ROUTES[key];
          $(`#${elementId}`).addEventListener('click', router.route);
        }
    }

    function registerBackButton() {
      document.addEventListener('backbutton', () => history.back());
    }

    function registerHaptics() {
      for (const button of $('#navbar-bottom').children)
        button.addEventListener('click', (e) => {
          if (!e.target.parentElement.classList.contains('active'))
            hapticsUtil.tapDefault();
        });
    }

    function displayBadge({ element, id, number }) {
      const existingBadge = $('#' + id);
      if (number === 0) {
        existingBadge?.remove();
        return;
      }
      if (existingBadge) {
        existingBadge.innerText = number;
        return;
      }
      const badge = documentUtil.createHtmlElement({
        element: 'div',
        className: 'badge primary',
        innerText: number,
        id
      });
      element.appendChild(badge);
    }

    function init(_router) {
      router = _router;
      registerRoutes();
      registerBackButton();
      registerHaptics();
      updateSelection();
      router.addLocationChangeListener(updateSelection);
    }

    return { init, show, hide, getHtml, displayBadge };
  }
  window.modules = window.modules || {};
  window.modules.Navbar = Navbar;
})();
