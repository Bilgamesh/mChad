import { AndroidUtil } from '../../../utils/android.js';
import { BBCode } from './bbcode.js';

function BBCodesPanel({ bbtags }) {
  const androidUtil = AndroidUtil();

  let html = '';
  let keyboardOffListenerId;

  /* Some BBCodes have alternative versions created on specific forums
    by the forum administrators. In such cases, they prefer the custom BBcodes
    to be used instead of the original one. One example is [mimg] which is a
    BBcode used for displaying images, but it decreases the size of an image
    to fit the chat message, as opposed to [img]. This application is going
    to hide the original BBcodes if custom alternatives are provided. */
  const BBTAGS_CONFIG = {
    b: { icon: 'format_bold' },
    i: { icon: 'format_italic' },
    u: { icon: 'format_underlined' },
    quote: { icon: 'format_quote' },
    code: { icon: 'data_object' },
    img: { icon: 'image', alternatives: ['mimg', 'image'] },
    url: { icon: 'link' },
    s: { icon: 'format_strikethrough' },
    pre: { icon: 'format_size' },
    sub: { icon: 'subscript' },
    fade: { icon: 'transition_fade' },
    sup: { icon: 'superscript' },
    spoil: { icon: 'visibility_off', alternatives: ['spoiler'] },
    spoiler: { icon: 'visibility_off' },
    hidden: { icon: 'lock' },
    offtopic: { icon: 'sms' },
    soundcloud: { icon: 'music_note' },
    BBvideo: { icon: 'movie' },
    image: { icon: 'image', alternatives: ['mimg'] },
    mimg: { icon: 'image' },
    g: { icon: 'keyboard_arrow_right' },
    youtube: { icon: 'youtube_activity' }
  };

  /* BBCodes this app doesn't support yet
    due additional work on GUI required */
  const BBTAGS_BLACKLIST = [
    'list',
    'list=',
    'flash=',
    'size=',
    'font',
    'highlight',
    'align',
    'float',
    'glow',
    'dropshadow',
    'blur',
    'marq',
    'shadow',
    'dir',
    'nfo',
    'pipes'
  ];

  function formatBBTags(bbtags) {
    const updated = [];
    for (const bbtag of bbtags) {
      if (BBTAGS_BLACKLIST.includes(bbtag.name)) continue;
      // Identify and skip inferior alternative BBCodes
      const alternatives = BBTAGS_CONFIG[bbtag.name]?.alternatives || [];
      let foundAlternative;
      for (const alternative of alternatives)
        if (bbtags.find((tag) => tag.name === alternative))
          foundAlternative = true;
      if (foundAlternative) continue;
      bbtag.icon = BBTAGS_CONFIG[bbtag.name]?.icon;
      updated.push(bbtag);
    }
    return updated;
  }

  function init() {
    html += /* HTML */ `<nav
      id="bbcodes-panel"
      class="row scroll page bbcodes-panel"
      hide="true"
    >
      ${getBBCodesHtml()}
    </nav>`;
  }

  function getHtml() {
    return html;
  }

  function getBBCodesHtml() {
    let bbcodesHtml = '';
    for (const bbtag of formatBBTags(bbtags))
      bbcodesHtml += BBCode({
        bbtag,
        hide: false
      }).getHtml();
    return bbcodesHtml;
  }

  function registerListeners() {
    if (!document.hideBBCodesOnBlurListenerAdded) {
      document.addEventListener('click', hideBBCodesOnBlur);
      document.hideBBCodesOnBlurListenerAdded = true;
    }
    keyboardOffListenerId = androidUtil.addKeyboardOffListener(hideBBCodes);
    document
      .getElementById('bbcodes-panel-icon')
      .addEventListener('click', toggleBBCodes);
    for (const bbcodeElement of document.getElementsByClassName('bbcode'))
      if (bbcodeElement.getAttribute('hasListener') !== 'true')
        BBCode({ bbtag: {} }).addListeners(bbcodeElement);
  }

  function toggleBBCodes() {
    if (document.getElementById('bbcodes-panel').classList.contains('active'))
      hideBBCodes();
    else showBBCodes();
    document.getElementById('input-box').focus();
  }

  function showBBCodes() {
    document.getElementById('bbcodes-panel').classList.add('active');
    document.getElementById('bbcodes-panel').setAttribute('hide', 'false');
    for (const bbcode of document.getElementsByClassName('bbcode'))
      bbcode.setAttribute('hide', 'false');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('lifted-slightly', 'true');
  }

  function hideBBCodes() {
    document.getElementById('bbcodes-panel').classList.remove('active');
    document.getElementById('bbcodes-panel').setAttribute('hide', 'true');
    for (const bbcode of document.getElementsByClassName('bbcode'))
      bbcode.setAttribute('hide', 'true');
    document
      .getElementById('scroll-to-bottom-circle')
      .setAttribute('lifted-slightly', 'false');
  }

  function hideBBCodesOnBlur(event) {
    try {
      if (
        event.target === document.getElementById('bbcodes-panel-icon') ||
        event.target === document.getElementById('input-box') ||
        event.target?.classList?.contains('bbcode')
      )
        return;
      hideBBCodes();
    } catch (err) {
      console.log(
        `[${new Date().toLocaleString()}][BBCODES-PANEL] Failed to hide BBCodes on blur`
      );
    }
  }

  function update({ bbtags }) {
    // Don't modify bbcodes panel if there are already some bbcodes there
    // and user is using them
    if (
      document.getElementsByClassName('bbcode').length &&
      document.getElementById('bbcodes-panel').classList.contains('active')
    )
      return;
    if (bbtags.length > 0)
      document.getElementById('bbcodes-panel').innerHTML = '';
    for (const bbtag of formatBBTags(bbtags))
      BBCode({
        el: document.getElementById('bbcodes-panel'),
        bbtag,
        hide: false
      }).appendElement();
  }

  function onDestroy() {
    document.removeEventListener('click', hideBBCodesOnBlur);
    document.hideBBCodesOnBlurListenerAdded = false;
    androidUtil.removeKeyboardOffListener(keyboardOffListenerId);
  }

  return { init, update, registerListeners, getHtml, onDestroy };
}

export { BBCodesPanel };
