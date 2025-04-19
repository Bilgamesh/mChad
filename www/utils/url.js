function UrlUtil() {
  function convertUrlToName(baseUrl) {
    let name = baseUrl
      .toLowerCase()
      .replace('https://www.', '')
      .replace('https://', '')
      .split('/')[0];
    if (name.startsWith('www.')) name = name.replace('www.', '');
    return name.charAt(0).toUpperCase() + name.slice(1);
  }

  function getAllUrlPermutations(userProvidedUrl) {
    userProvidedUrl = userProvidedUrl.toLowerCase().replace('index.php', '');
    while (userProvidedUrl.endsWith('/'))
      userProvidedUrl = userProvidedUrl.slice(0, -1);
    let core = userProvidedUrl.replace('https://', '').replace('http://', '');
    if (core.startsWith('www.')) core = core.replace('www.', '');
    const permutations = [
      `https://${core}`,
      `https://www.${core}`,
      `http://${core}`,
      `http://www.${core}`
    ];
    if (userProvidedUrl.startsWith('https://'))
      permutations.unshift(userProvidedUrl);
    return Array.from(new Set(permutations));
  }

  return { convertUrlToName, getAllUrlPermutations };
}

export { UrlUtil };
