import { Languages } from '../../languages/languages.js';
import { sleep } from '../../utils/sleep.js';

async function Errors({ el }) {
  const languages = Languages();

  /* Emptying the page just before re-rendering
    and giving browser an overhead via dummy timeout
    makes BeerCSS transition animations much smoother */
  while (el.firstChild) el.removeChild(el.firstChild);
  await sleep(0);

  document.getElementById('body').setAttribute('page', 'errors');

  el.innerHTML = /* HTML */ `
    <h1>${await languages.getTranslation('PAGE_NOT_FOUND')}</h1>
  `;
}

export { Errors };
