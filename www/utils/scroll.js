(function () {
  function ScrollUtil(root) {
    function getScrollPercentage() {
      return root.scrollTop / (root.scrollHeight - root.clientHeight);
    }

    function isViewportNScreensAwayFromBottom(nScreens) {
      return root.scrollHeight - root.scrollTop > root.clientHeight * nScreens;
    }

    function checkScrollSpeed() {
      let lastPos,
        newPos,
        timer,
        delta,
        delay = 50; // in "ms" (higher means lower fidelity )

      function clear() {
        lastPos = null;
        delta = 0;
      }

      clear();

      return function () {
        newPos = Math.ceil(root.scrollTop);
        if (lastPos != null) {
          // && newPos < maxScroll
          delta = newPos - lastPos;
        }
        lastPos = newPos;
        clearTimeout(timer);
        timer = setTimeout(clear, delay);
        return delta;
      };
    }

    function isScrolledToTop() {
      return root.scrollTop < 1;
    }

    function isScrolledToBottom() {
      return Math.ceil(root.scrollTop) >= root.scrollHeight - root.offsetHeight;
    }

    function scrollUpBy(pixels) {
      root.scrollTo({
        top: root.scrollTop - pixels
      });
    }

    function scrollToBottom(behavior) {
      root.scrollTo({
        top: root.scrollHeight,
        behavior: behavior || 'instant'
      });
    }

    function scrollDownBy(pixels) {
      root.scrollTo({
        top: root.scrollTop + pixels
      });
    }

    return {
      getScrollPercentage,
      isViewportNScreensAwayFromBottom,
      checkScrollSpeed,
      isScrolledToTop,
      isScrolledToBottom,
      scrollUpBy,
      scrollToBottom,
      scrollDownBy
    };
  }
  window.modules = window.modules || {};
  window.modules.ScrollUtil = ScrollUtil;
})();
