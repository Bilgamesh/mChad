(function () {
  function InMemoryStore(dbName) {
    window.storage = window.storage || {};
    dbName = dbName.toLowerCase();

    function init() {
      window.storage[dbName] = window.storage[dbName] || {};
    }

    function set(key, value, index) {
      key = key.toLowerCase();
      if (typeof index === 'number') {
        window.storage[dbName][key] = window.storage[dbName][key] || [];
        window.storage[dbName][key][index] = value;
      } else window.storage[dbName][key] = value;
    }

    function add(key, value) {
      key = key.toLowerCase();
      window.storage[dbName][key] = window.storage[dbName][key] || [];
      window.storage[dbName][key].push(value);
    }

    function unshift(key, value) {
      key = key.toLowerCase();
      window.storage[dbName][key] = window.storage[dbName][key] || [];
      window.storage[dbName][key].unshift(value);
    }

    function get(key, index = null) {
      key = key.toLowerCase();
      if (typeof index === 'number') return window.storage[dbName][key][index];
      return window.storage[dbName][key];
    }

    function getLength(key) {
      key = key.toLowerCase();
      return window.storage[dbName][key].length;
    }

    function has(key) {
      key = key.toLowerCase();
      if (Array.isArray(window.storage[dbName][key]))
        return !!window.storage[dbName][key].length;
      return window.storage[dbName][key] !== undefined;
    }

    function del(key, index = null) {
      key = key.toLowerCase();
      const data = get(key, index);
      if (typeof index === 'number')
        window.storage[dbName][key].splice(index, 1);
      else delete window.storage[dbName][key];
      return data;
    }

    function contains(key, checkFunc) {
      key = key.toLowerCase();
      const values = get(key) || [];
      for (const value of values) if (checkFunc(value)) return true;
      return false;
    }

    function sort(key, sortFunc) {
      key = key.toLowerCase();
      let values = get(key);
      values = values.sort(sortFunc);
      set(key, values);
    }

    function findIndex(key, findFunc) {
      key = key.toLowerCase();
      const values = get(key);
      return values.findIndex(findFunc);
    }

    function splice(key, start, count) {
      key = key.toLowerCase();
      const values = [...get(key)];
      if (count) return values.splice(start, count);
      else return values.splice(start);
    }

    function clear() {
      window.storage[dbName] = {};
    }

    init();

    return {
      set,
      add,
      unshift,
      get,
      getLength,
      has,
      del,
      contains,
      sort,
      clear,
      findIndex,
      splice
    };
  }

  window.modules = window.modules || {};
  window.modules.InMemoryStore = InMemoryStore;
})();
