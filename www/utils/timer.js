function Timer({ onTick } = {}) {
  let timer;
  let delayTimeout;
  let stopped = false;
  let _interval;

  if (cordova.platformId !== 'browser') {
    timer = new window.nativeTimer();
    timer.onTick = onTick;
  }

  function start({ interval, delay, onSuccess, onError }) {
    _interval = interval;
    if (stopped) return;
    if (cordova.platformId !== 'browser')
      timer.start(
        delay || 1,
        interval,
        onSuccess || (() => {}),
        onError || (() => {})
      );
    else
      try {
        clearInterval(timer);
        timer = setInterval(onTick, interval);
        delayTimeout = setTimeout(onTick, delay || 1);
        if (onSuccess) onSuccess();
      } catch (err) {
        if (onError) onError(err);
      }
  }

  function pause() {
    if (cordova.platformId !== 'browser') timer.stop();
    else {
      clearInterval(delayTimeout);
      clearInterval(timer);
    }
  }

  function resume() {
    start({ interval: _interval, delay: _interval });
  }

  function stop() {
    pause();
    stopped = true;
  }

  return { start, pause, resume, stop };
}

export { Timer };
