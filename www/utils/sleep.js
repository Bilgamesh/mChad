(function () {
  function sleep(ms) {
    return new Promise((r) => setTimeout(r, ms));
  }

  window.modules = window.modules || {};
  window.modules.sleep = sleep;
})();
