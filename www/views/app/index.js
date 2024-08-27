(function () {
  const {
    Config,
    PersistentStore,
    FetchTool,
    ThemeUtil,
    Navbar,
    Errors,
    Chat,
    Settings,
    Accounts,
    Login,
    Languages,
    MchatGlobalSynchronizer,
    MchatSingleSynchronizer,
    CookieStore,
    MchatChatService,
    MchatUserService,
    MchatEmoticonsService,
    InMemoryStore,
    Popups,
    DocumentUtil,
    ChatUi,
    AndroidUtil,
    AnimationsUtil,
    HapticsUtil,
    ChatEvents,
    Events,
    sleep,
    AccountsUi,
    LoginUi,
    LoginActions,
    MchatLoginService,
    UrlUtil,
    SettingsUi,
    Router,
    Message,
    Emoticon,
    AccountArticle,
    SettingsActions,
    AccountsActions,
    NavbarBadges,
    AppUi,
    BackgroundSynchronizer,
    NotificationsService,
    LocalNotifications,
    TimeUtil,
    Timer,
    EmoticonPanel,
    ToolsPanel,
    BBCode,
    BBCodesPanel,
    ClipboardUtil
  } = window.modules;

  document.addEventListener(
    'deviceready',
    async () => {
      const themeUtil = ThemeUtil(PersistentStore);
      const languages = Languages(PersistentStore);
      const androidUtil = AndroidUtil(themeUtil);
      const animationsUtil = AnimationsUtil();
      const hapticsUtil = HapticsUtil(PersistentStore);
      const documentUtil = DocumentUtil(hapticsUtil);
      const timeUtil = TimeUtil(languages);
      const urlUtil = UrlUtil();
      const clipboardUtil = ClipboardUtil();
      const events = Events();

      const navbar = await Navbar({ languages, hapticsUtil, documentUtil });

      const appUi = AppUi({
        el: $('#body'),
        navbar,
        languages,
        sleep,
        PersistentStore
      });

      const badges = NavbarBadges({
        navbar,
        documentUtil,
        PersistentStore,
        InMemoryStore
      });

      await appUi.displayPage();

      const config = await Config(PersistentStore, themeUtil);
      const fetchTool = FetchTool(config);

      const popups = Popups(hapticsUtil, documentUtil);

      const globalSynchronizer = MchatGlobalSynchronizer({
        PersistentStore,
        MchatSingleSynchronizer,
        CookieStore,
        MchatChatService,
        MchatUserService,
        MchatEmoticonsService,
        InMemoryStore,
        fetchTool,
        config,
        documentUtil,
        languages,
        popups,
        Timer
      });

      const backgroundSynchronizer = BackgroundSynchronizer({
        PersistentStore,
        MchatChatService,
        CookieStore,
        InMemoryStore,
        fetchTool,
        config,
        documentUtil
      });

      globalSynchronizer.addSyncListener('refresh-end', badges.refreshBadges);

      const router = Router({
        Errors,
        Chat,
        Settings,
        Accounts,
        Login,
        languages,
        PersistentStore,
        globalSynchronizer,
        documentUtil,
        androidUtil,
        ChatUi,
        animationsUtil,
        hapticsUtil,
        ChatEvents,
        InMemoryStore,
        events,
        sleep,
        AccountsUi,
        LoginUi,
        themeUtil,
        LoginActions,
        MchatLoginService,
        urlUtil,
        fetchTool,
        SettingsUi,
        config,
        CookieStore,
        navbar,
        Message,
        Emoticon,
        AccountArticle,
        SettingsActions,
        AccountsActions,
        badges,
        popups,
        timeUtil,
        Timer,
        EmoticonPanel,
        ToolsPanel,
        BBCode,
        BBCodesPanel,
        clipboardUtil
      });

      const localNotifications = LocalNotifications({
        NotificationsService,
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
})();
