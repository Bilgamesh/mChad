(function () {
  const storage = {};

  function InMemoryStore(dbName) {
    dbName = dbName.toLowerCase();

    function init() {
      storage[dbName] = storage[dbName] || {};
    }

    function set(key, value, index) {
      key = key.toLowerCase();
      if (typeof index === 'number') {
        storage[dbName][key] = storage[dbName][key] || [];
        storage[dbName][key][index] = value;
      } else storage[dbName][key] = value;
    }

    function add(key, value) {
      key = key.toLowerCase();
      storage[dbName][key] = storage[dbName][key] || [];
      storage[dbName][key].push(value);
    }

    function get(key, index = null) {
      key = key.toLowerCase();
      if (typeof index === 'number') return storage[dbName][key][index];
      return storage[dbName][key];
    }

    function has(key) {
      key = key.toLowerCase();
      if (Array.isArray(storage[dbName][key]))
        return !!storage[dbName][key].length;
      return storage[dbName][key] !== undefined;
    }

    function del(key, index = null) {
      key = key.toLowerCase();
      if (typeof index === 'number') storage[dbName][key].splice(index, 1);
      else delete storage[dbName][key];
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

    function clear() {
      storage[dbName] = {};
    }

    init();

    return {
      set,
      add,
      get,
      has,
      del,
      contains,
      sort,
      clear
    };
  }

  window.modules = window.modules || {};
  window.modules.InMemoryStore = InMemoryStore;
})();
