import { Languages } from '../languages/languages.js';

function TimeUtil() {
  const languages = Languages();
  async function createTimeAgoMessage(secondsAgo) {
    const lessThanSecondAgoText = await languages.getTranslation(
      'LESS_THAN_SECOND_AGO'
    );
    const secondAgoText = await languages.getTranslation('SECOND_AGO');
    const secondsAgoText = await languages.getTranslation('SECONDS_AGO');
    const secondsAgo2Text = await languages.getTranslation('SECONDS_AGO_2');
    if (secondsAgo === 0) return lessThanSecondAgoText;
    if (secondsAgo === 1) return `${secondsAgo} ${secondAgoText}`;
    if (secondsAgo < 60 && ['2', '3', '4'].includes(`${secondsAgo}`.slice(-1)))
      return `${secondsAgo} ${secondsAgoText}`;
    if (secondsAgo < 60) return `${secondsAgo} ${secondsAgo2Text}`;
    moment.locale(languages.getCurrentLanguage());
    return moment(new Date().getTime() - secondsAgo * 1000).fromNow();
  }

  async function timestampToTimeAgo(time) {
    const diffMs = new Date().getTime() - time;
    const diffSec = Math.floor(diffMs / 1000);
    return await createTimeAgoMessage(diffSec);
  }

  return {
    createTimeAgoMessage,
    timestampToTimeAgo
  };
}

export { TimeUtil };
