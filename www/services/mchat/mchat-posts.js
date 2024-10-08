(function () {
  function MchatChatService({ baseUrl, cookieStore, fetchTool, documentUtil }) {
    async function fetchMainPage() {
      try {
        const options = {
          method: 'GET',
          headers: {
            accept:
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
            cookie: await cookieStore.get()
          }
        };
        const response = await fetchTool.fetchCrossDomain(
          `${baseUrl}/index.php`,
          options
        );
        const html = await response.text();
        const doc = new DOMParser().parseFromString(html, 'text/html');
        const bbtags = documentUtil.extractBBtags(doc);
        const messages = parseMessages(html);
        const formToken = documentUtil.findInputData(
          doc,
          'form_token',
          'value'
        );
        const creationTime = documentUtil.findInputData(
          doc,
          'creation_time',
          'value'
        );
        if (messages.length === 0) {
          console.log(
            `[${new Date().toLocaleString()}][MCHAT-CHAT-SERVICE] No posts found in main page HTML`
          );
          throw 'Could not fetch main page from server';
        }
        let cookie = '';
        if (documentUtil.hasSessionCookie(response))
          cookie = documentUtil.extractCookie(response.headers);
        return { messages, bbtags, cookie, formToken, creationTime };
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][MCHAT-CHAT-SERVICE] Error: ${err}`
        );
        throw 'Could not fetch main page from server';
      }
    }

    async function refresh(last, log) {
      const options = {
        method: 'POST',
        headers: {
          'x-requested-with': 'XMLHttpRequest',
          'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
          cookie: await cookieStore.get()
        },
        body: { last, log, _referer: `${baseUrl}/index.php` }
      };
      const url = `${baseUrl}/app.php/mchat/action/refresh`;
      const response = await fetchTool.fetchCrossDomain(url, options);
      const json = await response.json();
      if (json.add) json.add = parseMessages(json.add);
      if (json.edit) json.edit = parseMessages(json.edit);
      let cookie = '';
      if (documentUtil.hasSessionCookie(response))
        cookie = documentUtil.extractCookie(response.headers);
      return { ...json, cookie };
    }

    async function add({ last, text, formToken, creationTime }) {
      try {
        const options = {
          method: 'POST',
          headers: {
            'x-requested-with': 'XMLHttpRequest',
            'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
            cookie: await cookieStore.get()
          },
          body: {
            last,
            message: text,
            creation_time: creationTime,
            form_token: formToken
          }
        };
        const response = await fetchTool.fetchCrossDomain(
          `${baseUrl}/app.php/mchat/action/add`,
          options
        );
        const json = await response.json();
        if (json.add) json.add = parseMessages(json.add);
        if (json.edit) json.edit = parseMessages(json.edit);
        let cookie = '';
        if (documentUtil.hasSessionCookie(response))
          cookie = documentUtil.extractCookie(response.headers);
        return { ...json, cookie };
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][MCHAT-CHAT-SERVICE] Error: ${err}`
        );
        if (documentUtil.isJSON(err)) {
          const parsedError = JSON.parse(err);
          if (parsedError.message) throw parsedError.message;
        }
        throw 'Could send message to server';
      }
    }

    // TODO
    async function edit() {}
    // TODO
    async function del() {}

    async function fetchArchive(startIndex = 0) {
      let cookie = '';
      try {
        const options = {
          method: 'GET',
          headers: {
            accept:
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
            cookie: await cookieStore.get()
          }
        };
        const response = await fetchTool.fetchCrossDomain(
          `${baseUrl}/app.php/mchat/archive?start=${startIndex}`,
          options
        );
        if (documentUtil.hasSessionCookie(response))
          cookie = documentUtil.extractCookie(response.headers);
        const html = await response.text();
        const messages = parseMessages(html);
        if (messages.length === 0) {
          console.log(
            `[${new Date().toLocaleString()}][MCHAT-CHAT-SERVICE] No posts found in archive HTML`
          );
          return { cookie };
        }
        return { messages, cookie };
      } catch (err) {
        console.log(
          `[${new Date().toLocaleString()}][MCHAT-CHAT-SERVICE] Error: ${err}`
        );
        return { cookie };
      }
    }

    function parseMessages(html) {
      const doc = new DOMParser().parseFromString(html, 'text/html');
      const messageElements = doc.getElementsByClassName('row mchat-message');
      const likeMessage = documentUtil.extractLikeMessage(doc);
      const logId = documentUtil.extractLogId(doc);
      const messages = [];
      for (const element of messageElements)
        messages.push({
          id: element.getAttribute('data-mchat-id'),
          time: element.getAttribute('data-mchat-message-time'),
          user: {
            id: element.getAttribute('data-mchat-user-id'),
            name: element.getAttribute('data-mchat-username')
          },
          message: {
            text: element.getAttribute('data-mchat-message'),
            html: element.getElementsByClassName('mchat-text')[0].innerHTML
          },
          avatar: {
            src: (
              element.getElementsByClassName('avatar')[0] ||
              element.getElementsByClassName('mchat-avatar')[1]
            ).getAttribute('src'),
            width: (
              element.getElementsByClassName('avatar')[0] ||
              element.getElementsByClassName('mchat-avatar')[1]
            ).getAttribute('width')
          },
          likeMessage,
          logId
        });
      return messages.sort((a, b) => a.id - b.id);
    }

    return { fetchMainPage, fetchArchive, refresh, add, edit, del };
  }

  window.modules = window.modules || {};
  window.modules.MchatChatService = MchatChatService;
})();
