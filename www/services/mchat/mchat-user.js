(function () {
  function MchatUserService({
    baseUrl,
    userId,
    cookieStore,
    fetchTool,
    documentUtil
  }) {
    async function fetchProfile() {
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
          `${baseUrl}/memberlist.php?mode=viewprofile&u=${userId}`,
          options
        );
        let cookie;
        if (documentUtil.hasSessionCookie(response))
          cookie = documentUtil.extractCookie(response.headers);
        const html = await response.text();
        const doc = new DOMParser().parseFromString(html, 'text/html');
        const avatarUrl = doc.getElementsByClassName('avatar')[0]
          ? baseUrl +
            doc
              .getElementsByClassName('avatar')[0]
              .getAttribute('src')
              .substring(1)
          : './img/no_avatar.gif';
        const username = (
          doc.getElementsByClassName('username')[0] ||
          doc.getElementsByClassName('username-coloured')[0]
        ).innerHTML;
        return { avatarUrl, username, cookie };
      } catch (err) {
        console.error(err);
        throw 'Could not fetch messages from server';
      }
    }

    return {
      fetchProfile
    };
  }

  window.modules = window.modules || {};
  window.modules.MchatUserService = MchatUserService;
})();
