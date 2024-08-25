(function () {
  async function Errors({ el, languages, sleep }) {
    /* Emptying the page just before re-rendering
    and giving browser an overhead via dummy timeout
    makes BeerCSS transition animations much smoother */
    while (el.firstChild) el.removeChild(el.firstChild);
    await sleep(0);

    $('#body').setAttribute('page', 'errors');

    el.innerHTML = /* HTML */ `
      <h1>${await languages.getTranslation('PAGE_NOT_FOUND')}</h1>
    `;
  }

  window.modules = window.modules || {};
  window.modules.Errors = Errors;
})();
