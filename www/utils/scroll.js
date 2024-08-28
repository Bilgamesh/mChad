(function () {
  function ScrollUtil(root) {
    function getScrollPercentage() {
      return root.scrollTop / (root.scrollHeight - root.clientHeight);
    }

    function isViewportNScreensAwayFromBottom(nScreens) {
      return root.scrollHeight - root.scrollTop > root.clientHeight * nScreens;
    }

    return { getScrollPercentage, isViewportNScreensAwayFromBottom };
  }
  window.modules = window.modules || {};
  window.modules.ScrollUtil = ScrollUtil;
})();
