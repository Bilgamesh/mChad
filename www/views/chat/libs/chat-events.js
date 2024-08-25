(function () {
  function ChatEvents(chatUi, hapticsUtil) {
    const storedTouch = {
      startX: null,
      startY: null,
      currentX: null,
      currentY: null,
      moved: false,
      X_MAX_DIFF: 10,
      Y_MAX_DIFF: 10
    };
    let enlargeTimeout;

    function updateStoredTouch({ startX, startY, currentX, currentY }) {
      storedTouch.startX = startX || storedTouch.startX;
      storedTouch.startY = startY || storedTouch.startY;
      storedTouch.currentX = currentX || storedTouch.currentX;
      storedTouch.currentY = currentY || storedTouch.currentY;

      const diffX = Math.abs(storedTouch.startX - storedTouch.currentX);
      const diffY = Math.abs(storedTouch.startY - storedTouch.currentY);

      storedTouch.moved =
        storedTouch.moved ||
        diffX >= storedTouch.X_MAX_DIFF ||
        diffY >= storedTouch.Y_MAX_DIFF;
    }

    function onBubbleTouchmove(e) {
      const { X, Y } = extractTouchCoordinates(e);
      updateStoredTouch({ currentX: X, currentY: Y });
      if (storedTouch.moved) {
        clearTimeout(enlargeTimeout);
        chatUi.shrinkAllBubbles();
      }
    }

    function extractTouchCoordinates(e) {
      if (e.changedTouches)
        return { X: e.changedTouches[0].pageX, Y: e.changedTouches[0].pageY };
      return { X: e.pageX, Y: e.pageY };
    }

    function onBubbleTouchdown(e) {
      storedTouch.moved = false;
      const { X, Y } = extractTouchCoordinates(e);
      updateStoredTouch({ startX: X, startY: Y, currentX: X, currentY: Y });
      const target = findTargetBubble(e.target) || e.target;
      enlargeTimeout = setTimeout(() => chatUi.enlarge(target), 50);
    }

    function onBubbleTouchend(e) {
      clearTimeout(enlargeTimeout);
      chatUi.shrinkAllBubbles();
      const targetBubble = findTargetBubble(e.target);
      for (const element of document.getElementsByClassName('bubble'))
        if (!storedTouch.moved && targetBubble !== element)
          chatUi.stopShaking(element);
      if (
        (!targetBubble || !chatUi.isShaking(targetBubble)) &&
        !storedTouch.moved
      )
        setTimeout(chatUi.hideToolbar, 50);
    }

    function onBubbleLongpress(e) {
      chatUi.stopShakingAllBubbles();
      chatUi.hideToolbar();
      const target = findTargetBubble(e.target) || e.target;
      if (chatUi.isShaking(target)) return;
      chatUi.startShaking(target);
      if (e.target.nodeName !== 'IMG') hapticsUtil.longPress();
      if (chatUi.isAnyBubbleShaking()) chatUi.showToolbar();
    }

    function findTargetBubble(target) {
      return chatUi.findBubbleByChild(target);
    }

    return {
      onBubbleTouchmove,
      onBubbleTouchdown,
      onBubbleTouchend,
      onBubbleLongpress
    };
  }

  window.modules = window.modules || {};
  window.modules.ChatEvents = window.ChatEvents || ChatEvents;
})();
