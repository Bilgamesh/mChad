(function () {
  function Events() {
    return {
      TOUCHSTART: cordova.platformId === 'browser' ? 'mousedown' : 'touchstart',
      TOUCHEND: cordova.platformId === 'browser' ? 'mouseup' : 'touchend',
      TOUCHMOVE: cordova.platformId === 'browser' ? 'mousemove' : 'touchmove',
      LONGPRESS: 'long-press'
    };
  }
  window.modules = window.modules || {};
  window.modules.Events = Events;
})();
