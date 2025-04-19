import { DocumentUtil } from '../../utils/document.js';

function MchatOnlineUsersService({ baseUrl, cookieStore, fetchTool }) {
  const documentUtil = DocumentUtil();
  async function fetchUsers() {
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
        `${baseUrl}/viewonline.php`,
        options
      );
      let cookie;
      if (documentUtil.hasSessionCookie(response))
        cookie = documentUtil.extractCookie(response.headers);
      const html = await response.text();
      const doc = new DOMParser().parseFromString(html, 'text/html');
      const message = doc.querySelector('.viewonline-title').innerText;
      const table = doc.querySelector('tbody');
      const users = [];
      for (const row of table.children) {
        const username = row.querySelector('[class^=username]').innerText;
        users.push({ username });
      }
      const visibleCount = users.length;
      const counts = message.match(/\d+/gi) || [0];
      const totalCount = counts.reduce((accumulator, currentValue) => {
        return +accumulator + +currentValue;
      }, 0);
      const hiddenCount = totalCount - visibleCount;
      return {
        message,
        users,
        cookie,
        visibleCount,
        hiddenCount,
        totalCount
      };
    } catch (err) {
      console.log(
        `[${new Date().toLocaleString()}][MCHAT-ONLINE-USERS-SERVICE] Error: ${err}`
      );
      throw 'Could not fetch messages from server';
    }
  }

  return {
    fetchUsers
  };
}

export { MchatOnlineUsersService };
