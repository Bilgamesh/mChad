import { Config } from '../../config.js';
import { FetchTool } from '../../utils/fetch-cross-domain.js';
import { Navbar } from './scripts/navbar.js';
import { MchatGlobalSynchronizer } from '../../jobs/mchat/mchat-global-sync.js';
import { Popups } from './scripts/pop-ups.js';
import { DocumentUtil } from '../../utils/document.js';
import { AndroidUtil } from '../../utils/android.js';
import { Router } from '../../router/router.js';
import { NavbarBadges } from './scripts/badges.js';
import { AppUi } from './scripts/app-ui.js';
import { BackgroundSynchronizer } from '../../jobs/background-sync.js';
import { LocalNotifications } from './scripts/local-notifications.js';

document.addEventListener(
  'deviceready',
  async () => {
    const androidUtil = AndroidUtil();
    const documentUtil = DocumentUtil();

    // Prevent screen rotation while calculating statusBarHeight
    screen.orientation.lock(screen.orientation.type);
    androidUtil.makeStatusBarTransparent().then((statusBarHeight) => {
      documentUtil.expandHeaderBy(statusBarHeight);
      androidUtil.refreshKeyboardDetection();
      window.addEventListener(
        'orientationchange',
        androidUtil.reverseScreenRatios
      );
    });

    const navbar = await Navbar();

    const appUi = AppUi({
      el: document.getElementById('body'),
      navbar
    });

    const badges = NavbarBadges({
      navbar
    });

    await appUi.displayPage();

    const config = await Config();
    const fetchTool = FetchTool(config);

    const popups = Popups();

    const globalSynchronizer = MchatGlobalSynchronizer({
      config,
      fetchTool,
      popups
    });

    const backgroundSynchronizer = BackgroundSynchronizer({
      fetchTool
    });

    globalSynchronizer.addSyncListener('refresh-end', badges.refreshBadges);

    const router = Router({
      config,
      globalSynchronizer,
      fetchTool,
      navbar,
      badges,
      popups
    });

    const localNotifications = LocalNotifications({
      config,
      router
    });

    router.init();
    router.handleLocation();
    navbar.init(router, globalSynchronizer);
    globalSynchronizer.startSync();
    router.addLocationChangeListener(badges.refreshBadges);
    backgroundSynchronizer.addSyncListener(localNotifications.notify);
    if (cordova.platformId !== 'browser') await backgroundSynchronizer.init();
  },
  false
);
