(function () {
  function InfiniteScroll() {
    let scrollUtil;
    let isInit = false;

    function init(_scrollUtil) {
      if (isInit) return;
      isInit = true;
      scrollUtil = _scrollUtil;
      $('#chat').addEventListener('scroll', onScroll);
    }

    function onScroll() {
        const scrollPercentage = scrollUtil.getScrollPercentage();
        if (scrollPercentage <= 0.2) return onApproachingTop();
        if (scrollPercentage >= 0.8) return onApproachingBottom();
    }

    function onApproachingTop() {
        console.log('top');
    }

    function onApproachingBottom() {
        console.log('bottom');
    }

    function onDestroy() {
        $('#chat').removeEventListener('scroll', onScroll);
    }

    return { init, onDestroy };
  }
  window.modules = window.modules || {};
  window.modules.InfiniteScroll = InfiniteScroll;
})();
