(function () {
  function AnimationsUtil() {
    function fadeIn(element, timeMs) {
      element.style.opacity = 0;
      let last = +new Date();
      const tick = function () {
        element.style.opacity =
          +element.style.opacity + (new Date() - last) / timeMs;
        last = +new Date();
        if (+element.style.opacity < 1)
          (window.requestAnimationFrame && requestAnimationFrame(tick)) ||
            setTimeout(tick, 16);
      };
      tick();
    }

    function removeFadeOut(el, speed) {
      var seconds = speed / 1000;
      el.style.transition = 'opacity ' + seconds + 's ease';

      el.style.opacity = 0;
      setTimeout(function () {
        try {
          el.parentNode.removeChild(el);
        } catch (err) {}
      }, speed);
    }

    function getClickEffect(element) {
      return function () {
        try {
          element?.classList.remove('unhoverable');
          setTimeout(() => {
            try {
              element?.classList.add('unhoverable');
            } catch (err) {}
          }, 500);
        } catch (err) {}
      };
    }

    return { fadeIn, removeFadeOut, getClickEffect };
  }

  window.modules = window.modules || {};
  window.modules.AnimationsUtil = AnimationsUtil;
})();
