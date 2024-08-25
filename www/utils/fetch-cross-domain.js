(function () {
  function FetchTool(config) {
    function setDataSerializer(header) {
      switch (header) {
        case 'application/x-www-form-urlencoded':
          return cordova.plugin.http.setDataSerializer('urlencoded');
        case 'application/x-www-form-urlencoded; charset=UTF-8':
          return cordova.plugin.http.setDataSerializer('urlencoded');
        default:
          return cordova.plugin.http.setDataSerializer('json');
      }
    }

    function addUrlParameters(url, parameters) {
      for (const { key, value } of parameters) {
        const separator = url.includes('?') ? '&' : '?';
        url = `${url}${separator}${encodeURIComponent(
          key
        )}=${encodeURIComponent(value)}`;
      }
      return url;
    }

    function request(url, options) {
      return new Promise((resolve, reject) => {
        console.log(
          `[${new Date().toLocaleString()}] ${options.method} ${url}`
        );
        options.headers = options.headers || {};
        options.headers['user-agent'] =
          options.headers['user-agent'] || config.DEFAULT_USER_AGENT;
        setDataSerializer(options.headers['content-type']);
        cordova.plugin.http.setFollowRedirect(options.redirect !== 'manual');
        cordova.plugin.http.clearCookies();
        const timeParam = { key: '_time', value: new Date().getTime() };
        url = addUrlParameters(url, [timeParam]);
        const httpOptions = {
          method: options.method,
          data: options.body,
          headers: options.headers
        };
        cordova.plugin.http.sendRequest(
          url,
          httpOptions,
          (response) => onSuccess(resolve, reject, response, url),
          (response) => onFailure(resolve, reject, response, url)
        );
      });
    }

    function requestViaProxy(url, options) {
      return new Promise((resolve, reject) => {
        console.log(
          `[${new Date().toLocaleString()}] ${options.method} ${url}`
        );
        options.headers = options.headers || {};
        options.headers['Target-URL'] = url;
        if (options.headers.cookie)
          options.headers.kookie = options.headers.cookie;
        options.headers['user-operative'] =
          options.headers['user-agent'] || config.DEFAULT_USER_AGENT;
        const _url = url;
        url = config.PROXY_URL;
        setDataSerializer(options.headers['content-type']);
        const timeParam = { key: '_time', value: new Date().getTime() };
        url = addUrlParameters(url, [timeParam]);
        const httpOptions = {
          method: options.method,
          data: options.body,
          headers: options.headers
        };
        cordova.plugin.http.sendRequest(
          url,
          httpOptions,
          (response) => onSuccess(resolve, reject, response, _url),
          (response) => onFailure(resolve, reject, response, _url)
        );
      });
    }

    function onSuccess(resolve, reject, response, url) {
      try {
        console.log(
          `[${new Date().toLocaleString()}] ${url} ${response.status}`
        );
        if (config.USE_PROXY) {
          const { text, headers } = JSON.parse(response.data);
          response.data = text;
          response.headers = headers;
          response.headers['set-cookie'] = response.headers['set-kookie'];
        }
        return resolve({
          status: response.status,
          text: async () => response.data,
          json: async () => JSON.parse(response.data),
          headers: {
            get: (name) => response.headers[name]
          }
        });
      } catch (err) {
        reject(err);
      }
    }

    function onFailure(resolve, reject, response, url) {
      try {
        console.log(
          `[${new Date().toLocaleString()}] ${url} ${response.status}`
        );
        if (config.USE_PROXY) {
          const { text, headers } = JSON.parse(response.error);
          response.error = text;
          response.headers = headers;
          response.headers['set-cookie'] = response.headers['set-kookie'];
        }
        /* Status 302 redirect is returned as an error because we specifically disable redirect.
        Yet we need to return this response as a successful resolve, because we need to extract
        the cookies provided by phpBB in the redirect. */
        if (response.status === 302)
          return resolve({
            status: response.status,
            text: async () => response.error,
            json: async () => JSON.parse(response.error),
            headers: {
              get: (name) => response.headers[name]
            }
          });
        return reject(response.error);
      } catch (err) {
        reject(err);
      }
    }

    return { fetchCrossDomain: config.USE_PROXY ? requestViaProxy : request };
  }

  window.modules = window.modules || {};
  window.modules.FetchTool = FetchTool;
})();
