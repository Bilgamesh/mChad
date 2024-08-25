(function () {
  function PersistentStore(dbName) {
    dbName = dbName.toLowerCase();

    function init() {
      const storage = localStorage.getItem(dbName) || '{}';
      localStorage.setItem(dbName, storage);
    }

    function getStorage() {
      return JSON.parse(localStorage.getItem(dbName));
    }

    function updateStorage(storage) {
      localStorage.setItem(dbName, JSON.stringify(storage));
    }

    function set(key, value) {
      key = key.toLowerCase();
      const storage = getStorage();
      storage[key] = value;
      updateStorage(storage);
    }

    function add(key, value) {
      key = key.toLowerCase();
      const storage = getStorage();
      storage[key] = storage[key] || [];
      storage[key].push(value);
      updateStorage(storage);
      return storage[key].length;
    }

    function get(key, index = null) {
      key = key.toLowerCase();
      const storage = getStorage();
      if (typeof index === 'number') return storage[key][index];
      return storage[key];
    }

    function has(key) {
      key = key.toLowerCase();
      const storage = getStorage();
      if (Array.isArray(storage[key])) return !!storage[key].length;
      return storage[key] !== undefined;
    }

    function del(key, index = null) {
      key = key.toLowerCase();
      const storage = getStorage();
      if (typeof index === 'number') storage[key].splice(index, 1);
      else delete storage[key];
      updateStorage(storage);
    }

    function clear() {
      updateStorage({});
    }

    init();

    return { set, add, get, has, del, clear };
  }

  window.modules = window.modules || {};
  window.modules.PersistentStore = PersistentStore;
})();
