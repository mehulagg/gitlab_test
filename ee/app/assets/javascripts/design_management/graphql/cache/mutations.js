import { transformDesignUpload } from './transformations';

/**
 * Updates cache by merging and transforming
 * cached data with new data
 * @param {Object} store
 * @param {Object} query
 * @param {Object} data
 * @param {Function} transform
 */
const updateCache = (store, query, data, transform) => {
  const cacheData = store.readQuery(query);
  const newCacheData = transform(query, cacheData, data);
  store.writeQuery(newCacheData);
};

export const afterDesignUpload = (store, query, data) => {
  updateCache(store, query, data, transformDesignUpload);
};
