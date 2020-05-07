import useWindowLocation from './set_window_location_helper';

describe('setWindowLocation', () => {
  const originalLocation = window.location;

  afterEach(() => {
    expect(window.location).toBe(originalLocation);
  });

  useWindowLocation();

  it.each`
    property      | value
    ${'hash'}     | ${'#foo'}
    ${'host'}     | ${'gitlab.com'}
    ${'hostname'} | ${'gitlab.org'}
    ${'href'}     | ${'http://gitlab.org/foo#bar'}
    ${'origin'}   | ${'http://gitlab.com'}
    ${'pathname'} | ${'/foo/bar/baz'}
    ${'protocol'} | ${'https:'}
    ${'protocol'} | ${'http:'}
    ${'port'}     | ${'8080'}
    ${'search'}   | ${'?foo=bar&bar=foo'}
  `('sets "window.location.$property" to be "$value"', ({ property, value }) => {
    window.location[property] = value;

    expect(window.location[property]).toBe(value);
  });
});
