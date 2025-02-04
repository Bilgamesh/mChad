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

    function unshift(key, value) {
      key = key.toLowerCase();
      storage[dbName][key] = storage[dbName][key] || [];
      storage[dbName][key].unshift(value);
    }

    function get(key, index = null) {
      key = key.toLowerCase();
      if (typeof index === 'number') return storage[dbName][key][index];
      return storage[dbName][key];
    }

    function getLength(key) {
      key = key.toLowerCase();
      return storage[dbName][key].length;
    }

    function has(key) {
      key = key.toLowerCase();
      if (Array.isArray(storage[dbName][key]))
        return !!storage[dbName][key].length;
      return storage[dbName][key] !== undefined;
    }

    function del(key, index = null) {
      key = key.toLowerCase();
      const data = get(key, index);
      if (typeof index === 'number') storage[dbName][key].splice(index, 1);
      else delete storage[dbName][key];
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
      storage[dbName] = {};
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
