/**
 * setWindowLocation allows for setting `window.location`
 * (doing so directly is causing an error in jsdom)
 *
 * Example usage:
 * assert(window.location.hash === undefined);
 * setWindowLocation('http://example.com#foo')
 * assert(window.location.hash === '#foo');
 *
 * More information:
 * https://github.com/facebook/jest/issues/890
 *
 * @param url
 */

const useWindowLocation = () => {
  const originalLocationValue = window.location;

  beforeEach(() => {
    delete window.location;
    window.location = new URL(originalLocationValue.href);
  });

  afterEach(() => {
    window.location = originalLocationValue;
  });
};

export default useWindowLocation;
