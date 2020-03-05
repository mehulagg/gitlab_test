/**
 * Helper function to flush all current promises wich have not yet been processes
 * see https://github.com/facebook/jest/issues/2157#issuecomment-279171856
 * @returns {Promise}
 */
// eslint-disable-next-line import/prefer-default-export
export function flushPromises() {
  return new Promise(resolve => setImmediate(resolve));
}
