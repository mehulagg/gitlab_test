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

const locationProps = [
  'hash',
  'host',
  'hostname',
  'href',
  'origin',
  'pathname',
  'port',
  'protocol',
  'search',
];

const parseUrl = url => {
  const parsedUrl = new URL(url);

  return locationProps.reduce(
    (location, prop) => ({
      ...location,
      [prop]: parsedUrl[prop],
    }),
    {},
  );
};

const useWindowLocation = () => {
  const originalLocationValue = window.location;
  const newLocationValue = {};

  afterEach(() => {
    window.location = originalLocationValue;
  });

  locationProps.forEach(locationProp => {
    delete Object.defineProperty(window.location, locationProp, {
      get: () => newLocationValue[locationProp] || originalLocationValue[locationProp] || undefined,
      set: newValue => {
        newLocationValue[locationProp] = newValue;
      },
    });
  });
};

export default useWindowLocation;
