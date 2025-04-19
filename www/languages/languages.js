import { PersistentStore } from '../storage/persistent-store.js';

function Languages() {
  const cache = {};
  const preferencesStore = PersistentStore('app-preferences');

  async function getPresent() {
    const language = getCurrentLanguage();
    if (cache[language]) return cache[language];
    const response = await fetch(`/languages/data/${language}.json`);
    const json = await response.json();
    cache[language] = json;
    return json;
  }

  async function getTranslation(key) {
    const language = await getPresent();
    return language[key] || key;
  }

  async function translate() {
    const elements = document.querySelectorAll('[translation]');
    for (const element of elements) {
      const key = element.getAttribute('translation');
      element.innerText = await getTranslation(key);
    }
  }

  function getCurrentLanguage() {
    return preferencesStore.get('language') || window.navigator.language;
  }

  return { translate, getTranslation, getCurrentLanguage, getPresent };
}

export { Languages };
