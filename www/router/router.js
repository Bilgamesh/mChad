import { Chat } from '../views/chat/chat-controller.js';
import { Settings } from '../views/settings/settings-controller.js';
import { Accounts } from '../views/accounts/accounts-controller.js';
import { Errors } from '../views/errors/errors.js';
import { Image } from '../views/image/image-controller.js';
import { Login } from '../views/login/login-controller.js';
import { Queue } from '../utils/promise-queue.js';

function Router({
  config,
  navbar,
  globalSynchronizer,
  fetchTool,
  badges,
  popups
}) {
  const PAGE_ID = 'main-page';
  const ROUTES = {
    404: {
      script: Errors
    },
    '#chat': {
      elementId: 'chat-btn',
      script: Chat
    },
    '#settings': {
      elementId: 'settings-btn',
      script: Settings
    },
    '#accounts': {
      elementId: 'accounts-btn',
      script: Accounts
    },
    '#login': {
      script: Login
    },
    '#image': {
      script: Image
    }
  };
  const locationChangeListeners = [];
  const onDestroys = {};

  const queue = new Queue(1);

  const router = {
    init,
    ROUTES,
    handleLocation,
    redirect,
    loadView,
    route,
    addLocationChangeListener,
    addOnDestroy
  };

  window.router = router;

  function addLocationChangeListener(listen) {
    locationChangeListeners.push({ listen });
  }

  async function handleLocation() {
    const hash = window.location?.hash?.split('?')[0];
    if (!hash) return window.open('/#chat', '_self');
    if (hash.split('?')[0] === window.history.state?.prevHash.split('?')[0])
      return;
    const route = ROUTES[hash] || ROUTES[404];
    queue.enqueue(() =>
      loadView(route, PAGE_ID).then(() => {
        for (const listener of locationChangeListeners)
          listener.listen({ hash, route });
      })
    );
  }

  async function loadView(route, id = PAGE_ID) {
    await cleanPrevious(id);
    if (route.script)
      await route.script({
        el: document.getElementById(`${id}`),
        config,
        globalSynchronizer,
        router,
        navbar,
        fetchTool,
        badges,
        popups
      });
  }

  async function cleanPrevious(id = PAGE_ID) {
    document.getElementById(`${id}-css`)?.remove();
    const onDestroy = onDestroys[id];
    if (onDestroy) {
      await onDestroy();
      delete onDestroys[id];
    }
  }

  async function route(event) {
    event = event || window.event;
    event.preventDefault();
    window.history.pushState(
      { prevHash: window.location.hash },
      '',
      event.target.href || event.target.getAttribute('href')
    );
    await handleLocation();
  }

  async function redirect(routeName) {
    window.history.pushState(
      { prevHash: window.location.hash },
      '',
      window.location.origin + '/' + routeName
    );
    await handleLocation();
  }

  function addOnDestroy(onDestroy, id = PAGE_ID) {
    onDestroys[id] = onDestroy;
  }

  function init() {
    onpopstate = handleLocation;
  }

  return router;
}

export { Router };
