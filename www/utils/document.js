function $(selector) {
  if (selector.startsWith('#'))
    return document.getElementById(selector.substring(1));
  if (selector.startsWith('.'))
    return document.getElementsByClassName(selector.substring(1));
  const elements = document.querySelectorAll(selector);
  if (elements.length > 1) return elements;
  return elements[0];
}

function $$(selector) {
  return document.querySelectorAll(selector);
}

(function () {
  function DocumentUtil(hapticsUtil) {
    const USERNAME_COOKIE_REGEX = /.+_u=\d+/gi;
    const cachedImages = [];

    function getParam(param) {
      return new URLSearchParams(window.location.hash.split('?')[1]).get(param);
    }

    function onAllDocumentsLoad(callback) {
      Promise.all(
        Array.from(document.images)
          .filter((img) => !img.complete)
          .map(
            (img) =>
              new Promise((resolve) => {
                img.onload = img.onerror = resolve;
              })
          )
      ).then(callback);
    }

    function createElementFromHTML(htmlString) {
      return createElementsFromHTML(htmlString)[0];
    }

    function createElementsFromHTML(htmlString) {
      const template = document.createElement('template');
      template.innerHTML = htmlString.trim();
      return template.content.children;
    }

    function removeAllListeners(element) {
      const newElement = element.cloneNode(true);
      element.parentNode.replaceChild(newElement, element);
    }

    function unicodeToString(text) {
      return text.replace(/\\u[\dA-F]{4}/gi, function (match) {
        return String.fromCharCode(parseInt(match.replace(/\\u/g, ''), 16));
      });
    }

    function fixMessageLinks(baseUrl, message) {
      message = message
        .split('src="./')
        .join(`src="${baseUrl}/`)
        .split('href="./')
        .join(`href="${baseUrl}/`);
      message = fixImageLinks(message);
      message = fixEmbeddedYoutube(message);
      return message;
    }

    function fixImageLinks(message) {
      while (message.includes('<a href="')) {
        const url = message.split('<a href="')[1].split('"')[0];
        if (
          message.split('<a href="')[1].split('>')[1].startsWith('<img') &&
          (url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.gif') ||
            url.toLowerCase().endsWith('.svg') ||
            url.toLowerCase().endsWith('.webp'))
        )
          message = message.replace(
            /\<a href=".+?"/i,
            `<a class="clickable-image" image-url="${url}"`
          );
        else
          message = message.replace(
            /\<a href=".+?"/i,
            `<a class="clickable-link" target-url="${url}"`
          );
      }
      return message;
    }

    function fixEmbeddedYoutube(message) {
      while (message.includes('<iframe')) {
        const url = message
          .split('src="')[1]
          .split('"')[0]
          .replace('embed/', 'watch?v=');
        message = message
          .replace(
            /\<iframe /i,
            `<a class="clickable-link" target-url="${url}" `
          )
          .replace(/\><\/iframe\>/i, `>${url}</a>`);
      }
      return message;
    }

    function hasSessionCookie(page) {
      return (
        page.headers &&
        page.headers.get('set-cookie') &&
        page.headers.get('set-cookie') !== 'null'
      );
    }

    function extractUserId(cookie) {
      return cookie.match(USERNAME_COOKIE_REGEX)[0].split('=')[1];
    }

    function extractCookie(headers) {
      try {
        let result = '';
        const cookies = headers.get('set-cookie').split(', ');
        const authCookies = cookies.filter(
          (cookie) => !cookie.includes('HttpOnly')
        );
        for (const cookie of authCookies)
          result += ' ' + cookie.split(';')[0] + ';';
        return result.trim();
      } catch (err) {
        throw 'Invalid cookie header';
      }
    }

    function findInputData(doc, name, field) {
      try {
        if (name.startsWith('#'))
          return doc.querySelectorAll(name)[0].getAttribute(field);
        else
          return doc
            .querySelectorAll(`[name="${name}"]`)[0]
            .getAttribute(field);
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][DOCUMENT] Could not find input data: ${JSON.stringify(
            { name, field }
          )}`
        );
        return null;
      }
    }

    function extractLikeMessage(doc) {
      try {
        for (const script of doc.scripts) {
          if (script.innerText.includes('\tlikes\t')) {
            const [line] = /\tlikes\s+:\s'.+/gi.exec(script.innerText);
            return line.split("'")[1];
          }
        }
      } catch (err) {
        return '';
      }
    }

    function extractBBtags(doc) {
      try {
        for (const script of doc.scripts) {
          if (script.innerText.includes('bbtags = new Array(')) {
            const bbTagsArr = script.innerText
              .split('bbtags = new Array(')
              .pop()
              .split(');')[0]
              .split(',')
              .map((tag) => tag.replace(/'/g, '').trim());
            const bbTags = [];
            for (let i = 0; i < bbTagsArr.length; i += 2)
              bbTags.push({
                start: bbTagsArr[i],
                end: bbTagsArr[i + 1],
                name: bbTagsArr[i].slice(1, -1)
              });
            return bbTags;
          }
        }
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][DOCUMENT] Failed to extract BBtags due to error: ${err}`
        );
        return '';
      }
    }

    function extractEditDeleteLimit(doc) {
      try {
        for (const script of doc.scripts) {
          if (script.innerText.includes('editDeleteLimit')) {
            const limit = script.innerText
              .split('editDeleteLimit')[1]
              .split(',')[0]
              .replace(':', '')
              .trim();
            return +(limit || 0);
          }
        }
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][DOCUMENT] Failed to extract editDeleteLimit due to error: ${err}`
        );
        return 0;
      }
    }

    function extractLogId(doc) {
      try {
        for (const script of doc.scripts) {
          if (script.innerText.includes('\tlikes\t')) {
            const [line] = /logId\s+:\s\d+,/gi.exec(script.innerText);
            return line.split(': ')[1].split(',')[0];
          }
        }
      } catch (err) {
        return '';
      }
    }

    function isJSON(str) {
      try {
        JSON.parse(str);
        return true;
      } catch (err) {
        return false;
      }
    }

    function preloadImage(src, baseUrl, force) {
      if (baseUrl) src = src.replace('./', baseUrl + '/');
      if (cachedImages.includes(src) && !force) return;
      console.log(
        `[${new Date().toLocaleString()}][Document] Preloading image: ${src}`
      );
      if (!cachedImages.includes(src)) cachedImages.push(src);
      return new Promise((resolve) => {
        const image = new Image();
        image.onload = resolve;
        image.onerror = resolve;
        image.src = src;
      });
    }

    function reloadImages(address = '') {
      return Promise.all(
        cachedImages
          .filter((image) => image.includes(address))
          .map((image) => preloadImage(image, null, true))
      );
    }

    return {
      getParam,
      removeAllListeners,
      createElementFromHTML,
      createElementsFromHTML,
      onAllDocumentsLoad,
      unicodeToString,
      fixMessageLinks,
      hasSessionCookie,
      extractUserId,
      extractCookie,
      findInputData,
      extractLikeMessage,
      extractLogId,
      extractBBtags,
      extractEditDeleteLimit,
      isJSON,
      preloadImage,
      reloadImages
    };
  }

  window.modules = window.modules || {};
  window.modules.DocumentUtil = DocumentUtil;
})();
