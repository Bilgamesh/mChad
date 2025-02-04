(function () {
  function LocalNotifications({ NotificationsService, config, router }) {
    const notificationsService = NotificationsService();
    let background = false;

    document.addEventListener('pause', () => {
      background = true;
    });
    document.addEventListener('resume', () => {
      background = false;
    });

    notificationsService.addNotificationClickListener(
      openNotificationRelatedChat
    );

    async function notify({ forumName, userId, messages, forumIndex }) {
      if (messages[messages.length - 1].user.id == userId) return;
      const lastMessages = messages
        .filter((m) => !m.notificationSent && !m.read)
        .slice(Math.max(messages.length - config.MAX_NOTIFICATION_MESSAGES, 0));
      if (lastMessages.length === 0) return;
      for (const message of messages) message.notificationSent = true;
      if (background)
        await notificationsService.schedule([
          {
            id: forumIndex,
            title: forumName,
            text: lastMessages.map(({ user, message }) => ({
              person: user.name,
              message: message.text
            })),
            foreground: true,
            vibrate: true,
            icon: 'res://notif.png',
            smallIcon: 'res://notif.png',
            data: {
              forumIndex,
              lastMessageId: lastMessages[lastMessages.length - 1].id
            }
          }
        ]);
    }

    async function openNotificationRelatedChat({
      data: { forumIndex, lastMessageId }
    }) {
      await router.redirect('#accounts');
      await router.redirect(
        `#chat?forumIndex=${forumIndex}&goTo=${lastMessageId}`
      );
    }

    return { notify };
  }
  window.modules = window.modules || {};
  window.modules.LocalNotifications = LocalNotifications;
})();
