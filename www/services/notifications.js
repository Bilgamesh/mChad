(function () {
  function NotificationsService() {
    function schedule(notifications) {
      if (!notifications.length) return;
      return new Promise((resolve) => {
        cordova.plugins.notification.local.hasPermission((granted) => {
          if (granted)
            cordova.plugins.notification.local.schedule(notifications);
          resolve();
        });
      });
    }

    function addNotificationClickListener(listen) {
      cordova.plugins.notification.local.on('click', listen);
    }

    return { schedule, addNotificationClickListener };
  }
  window.modules = window.modules || {};
  window.modules.NotificationsService = NotificationsService;
})();
