function AnimationsUtil() {
  function fadeIn(element, timeMs, minOpacity = 0, maxOpacity = 1) {
    element.style.opacity = minOpacity;
    let last = +new Date();
    const tick = function () {
      element.style.opacity =
        +element.style.opacity + (new Date() - last) / timeMs;
      last = +new Date();
      if (+element.style.opacity < maxOpacity)
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

  function fadeOut(element, timeMs, minOpacity = 0, maxOpacity = 1) {
    element.style.opacity = maxOpacity;
    let last = +new Date();
    const tick = function () {
      element.style.opacity =
        +element.style.opacity - (new Date() - last) / timeMs;
      last = +new Date();
      if (+element.style.opacity > minOpacity)
        (window.requestAnimationFrame && requestAnimationFrame(tick)) ||
          setTimeout(tick, 16);
    };
    tick();
  }

  return { fadeIn, removeFadeOut, fadeOut };
}

export { AnimationsUtil };
