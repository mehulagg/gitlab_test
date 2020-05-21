import useWindowLocation from './set_window_location_helper';

const originalLocation = window.location;

describe('setWindowLocation', () => {
  describe('property assignments', () => {
    useWindowLocation();

    it.each`
      property      | value
      ${'hash'}     | ${'#foo'}
      ${'host'}     | ${'gitlab.com'}
      ${'hostname'} | ${'gitlab.org'}
      ${'href'}     | ${'http://gitlab.org/foo#bar'}
      ${'pathname'} | ${'/foo/bar/baz'}
      ${'protocol'} | ${'https:'}
      ${'protocol'} | ${'http:'}
      ${'port'}     | ${'8080'}
      ${'search'}   | ${'?foo=bar&bar=foo'}
    `('sets "window.location.$property" to be "$value"', ({ property, value }) => {
      window.location[property] = value;

      expect(window.location[property]).toBe(value);
    });

    it('sets the hash correctly', () => {
      window.location.href = 'http://foo.bar#baz';
      expect(window.location.hash).toBe('#baz');
    });
  });

  describe('cleanup', () => {
    it('has the original window location', () => {
      expect(window.location).toBe(originalLocation);
    });
  });
});
