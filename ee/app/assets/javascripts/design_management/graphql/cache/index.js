/**
 * Updates cache by merging and transforming
 * cached data with new data
 * @param {Object} store - Apollo store
 * @param {Object} data - new data
 * @param {Object} query - Apollo mutation query
 * @param {Function} transform - transform function to produce an updated cache data
 */
const updateCache = (store, data, query, transform) => {
  // 1. get the current state of the cache
  const cacheData = store.readQuery(query);
  // 2. create new version of cache
  const newCacheData = transform(cacheData, data);
  // 3. Set the cache
  store.writeQuery({ ...query, data: newCacheData });
};

export default updateCache;
