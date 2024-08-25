(function () {
  function SettingsUi({
    el,
    hapticsUtil,
    animationsUtil,
    languages,
    config,
    selectedLanguage,
    sleep
  }) {
    function init() {
      registerHaptics();
    }

    async function displayPage({ mode, localNotifications, hapticFeedback }) {
      /* Emptying the page just before re-rendering
      and giving browser an overhead via dummy timeout
      makes BeerCSS transition animations much smoother */
      while (el.firstChild) el.removeChild(el.firstChild);
      await sleep(0);

      el.innerHTML = /* HTML */ `<article
        id="main-article"
        class="main page active right"
      >
        <div class="space"></div>

        <nav>
          <h6 class="setting-label" translation="LIGHT_MODE">
            ${await languages.getTranslation('LIGHT_MODE')}
          </h6>
          <label class="switch icon setting">
            <input
              id="light-mode-toggle"
              type="checkbox"
              ${mode === 'light' ? 'checked' : ''}
            />
            <span>
              <i>dark_mode</i>
              <i>light_mode</i>
            </span>
          </label>
        </nav>

        <div class="space"></div>
        <div class="space"></div>
        <div class="space"></div>

        <nav>
          <h6 class="setting-label" translation="COLOR_THEME">
            ${await languages.getTranslation('COLOR_THEME')}
          </h6>
        </nav>
        <nav>
          <div id="colors" class="color-area">
            <button
              value="#F44336"
              class="circle small red unhoverable"
            ></button>
            <button
              value="#E91E63"
              class="circle small pink unhoverable"
            ></button>
            <button
              value="#9C27B0"
              class="circle small purple unhoverable"
            ></button>
            <button
              value="#673AB7"
              class="circle small deep-purple unhoverable"
            ></button>
            <button
              value="#3F51B5"
              class="circle small indigo unhoverable"
            ></button>
            <button
              value="#2196F3"
              class="circle small blue unhoverable"
            ></button>
            <button
              value="#03A9F4"
              class="circle small light-blue unhoverable"
            ></button>
            <button
              value="#00BCD4"
              class="circle small cyan unhoverable"
            ></button>
            <button
              value="#009688"
              class="circle small teal unhoverable"
            ></button>
            <button
              value="#4CAF50"
              class="circle small green unhoverable"
            ></button>
            <button
              value="#8BC34A"
              class="circle small light-green unhoverable"
            ></button>
            <button
              value="#CDDC39"
              class="circle small lime unhoverable"
            ></button>
            <button
              value="#FFEB3B"
              class="circle small yellow unhoverable"
            ></button>
            <button
              value="#FFC107"
              class="circle small amber unhoverable"
            ></button>
            <button
              value="#FF9800"
              class="circle small orange unhoverable"
            ></button>
            <button
              value="#FF5722"
              class="circle small deep-orange unhoverable"
            ></button>
            <button
              value="#795548"
              class="circle small brown unhoverable"
            ></button>
            <button
              value="#9E9E9E"
              class="circle small grey unhoverable"
            ></button>
            <button
              value="#607D8B"
              class="circle small blue-grey unhoverable"
            ></button>
            <button
              value="#000000"
              class="circle small black unhoverable"
            ></button>
            <button
              value="#FFFFFF"
              class="circle small white unhoverable"
            ></button>
          </div>
        </nav>

        <div class="space"></div>
        <div class="space"></div>
        <div class="space"></div>

        <nav>
          <h6 class="setting-label" translation="LOCAL_NOTIFICATIONS">
            ${await languages.getTranslation('LOCAL_NOTIFICATIONS')}
          </h6>
          <label class="switch icon setting">
            <input
              id="local-notifications-toggle"
              type="checkbox"
              ${localNotifications ? 'checked' : ''}
            />
            <span>
              <i>notifications</i>
              <i>notifications_active</i>
            </span>
          </label>
        </nav>
        <details class="setting-label-additional-info">
          <summary translation="WARNING">
            ${await languages.getTranslation('WARNING')}
          </summary>
          <p class="details-paragraph" translation="LOCAL_NOTIFICATIONS_INFO">
            ${await languages.getTranslation('LOCAL_NOTIFICATIONS_INFO')}
          </p>
        </details>

        <div class="space"></div>
        <div class="space"></div>
        <div class="space"></div>

        <nav>
          <h6 class="setting-label" translation="HAPTIC_FEEDBACK">
            ${await languages.getTranslation('HAPTIC_FEEDBACK')}
          </h6>
          <label class="switch icon setting">
            <input
              id="haptic-feedback-toggle"
              type="checkbox"
              ${(hapticFeedback === undefined ? true : hapticFeedback)
                ? 'checked'
                : ''}
            />
            <span>
              <i>smartphone</i>
              <i>edgesensor_high</i>
            </span>
          </label>
        </nav>

        <div class="space"></div>
        <div class="space"></div>
        <div class="space"></div>

        <nav>
          <h6 class="setting-label" translation="LANGUAGE">
            ${await languages.getTranslation('LANGUAGE')}
          </h6>
          <div class="field suffix round fill small setting">
            <select id="language-menu" class="unhoverable">
              ${await buildLanguageOptionsHtml()}
            </select>
            <i>arrow_drop_down</i>
          </div>
        </nav>

        <div class="space"></div>
        <div class="space"></div>
        <div class="space"></div>
      </article>`;
    }

    function registerHaptics() {
      $('#light-mode-toggle').addEventListener('click', hapticsUtil.tapDefault);
      $('#local-notifications-toggle').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      $('#haptic-feedback-toggle').addEventListener(
        'click',
        hapticsUtil.tapDefault
      );
      $('#language-menu').addEventListener('click', hapticsUtil.tapDefault);
      $('#language-menu').addEventListener('change', hapticsUtil.tapDefault);

      for (const color of $('#colors').children) {
        color.addEventListener('click', hapticsUtil.tapDefault);
        color.addEventListener('click', animationsUtil.getClickEffect(color));
      }
    }

    async function buildLanguageOptionsHtml() {
      let html;
      for (const { code, name } of config.SUPPORTED_LANGUAGES)
        html += /* HTML */ `<option
          value="${code}"
          translation="${name}"
          ${code === selectedLanguage ? 'selected' : ''}
        >
          ${await languages.getTranslation(name)}
        </option>`;
      return html;
    }

    function addHapticFeedbackToggleListener(listen) {
      $('#haptic-feedback-toggle').addEventListener('click', listen);
    }

    function addColorChangeListener(listen) {
      for (const color of $('#colors').children)
        color.addEventListener('click', listen);
    }

    function addLightModeToggleListener(listen) {
      $('#light-mode-toggle').addEventListener('click', listen);
    }

    function addLocalNotificationsToggleListener(listen) {
      $('#local-notifications-toggle').addEventListener('click', listen);
    }

    function addLanguageMenuChangeListener(listen) {
      $('#language-menu').addEventListener('change', listen);
    }

    return {
      init,
      displayPage,
      buildLanguageOptionsHtml,
      addHapticFeedbackToggleListener,
      addColorChangeListener,
      addLightModeToggleListener,
      addLocalNotificationsToggleListener,
      addLanguageMenuChangeListener
    };
  }

  window.modules = window.modules || {};
  window.modules.SettingsUi = SettingsUi;
})();
