(function () {
  function MchatEmoticonsService({
    baseUrl,
    cookieStore,
    fetchTool,
    documentUtil
  }) {
    async function fetchEmoticons(start = 0) {
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
          `${baseUrl}/posting.php?mode=smilies&f=0&start=${start}`,
          options
        );
        let cookie;
        if (documentUtil.hasSessionCookie(response))
          cookie = documentUtil.extractCookie(response.headers);
        const html = await response.text();
        const doc = new DOMParser().parseFromString(html, 'text/html');
        const hasHextPage = !!doc.getElementsByClassName('arrow next')[0];
        const emoticons = [];
        const imgs = doc.querySelectorAll('.inner > a > img');
        for (const img of imgs) {
          const pictureUrl = baseUrl + img.getAttribute('src').substring(1);
          const width = img.getAttribute('width');
          const height = img.getAttribute('height');
          const code = img.getAttribute('alt');
          const title = img.getAttribute('title');
          emoticons.push({ pictureUrl, width, height, code, title });
        }
        await preloadEmoticons(emoticons);
        return { emoticons, hasHextPage, count: emoticons.length, cookie };
      } catch (err) {}
    }

    function preloadEmoticons(emoticons) {
      return Promise.all(
        emoticons.map((emoticon) =>
          documentUtil.preloadImage(emoticon.pictureUrl)
        )
      );
    }

    return {
      fetchEmoticons
    };
  }

  window.modules = window.modules || {};
  window.modules.MchatEmoticonsService = MchatEmoticonsService;
})();
