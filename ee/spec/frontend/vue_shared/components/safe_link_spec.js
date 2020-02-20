import { shallowMount } from '@vue/test-utils';
import SafeLink from 'ee/vue_shared/components/safe_link.vue';
import { TEST_HOST } from 'spec/test_constants';

describe('SafeLink', () => {
  const httpLink = `${TEST_HOST}/safe_link.html`;
  // eslint-disable-next-line no-script-url
  const javascriptLink = 'javascript:alert("jay")';
  const linkText = 'Link Text';

  const linkProps = {
    hreflang: 'XR',
    rel: 'alternate',
    type: 'text/html',
    target: '_blank',
    media: 'all',
  };

  let wrapper;

  const factory = (propsData = {}) => {
    wrapper = shallowMount(SafeLink, {
      propsData,
      slots: {
        default: [linkText],
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('valid link', () => {
    beforeEach(() => {
      factory({ href: httpLink, ...linkProps });
    });

    it('renders a link element', () => {
      expect(wrapper.element.tagName).toBe('A');
    });

    it('renders link specific attributes', () => {
      expect(wrapper.attributes('href')).toBe(httpLink);
      Object.keys(linkProps).forEach(key => {
        expect(wrapper.attributes(key)).toBe(linkProps[key]);
      });
    });

    it('renders the inner text as provided', () => {
      expect(wrapper.text()).toBe(linkText);
    });
  });

  describe('invalid link', () => {
    beforeEach(() => {
      factory({ href: javascriptLink, ...linkProps });
    });

    it('renders a span element', () => {
      expect(wrapper.element.tagName).toBe('SPAN');
    });

    it('renders without link specific attributes', () => {
      expect(wrapper.attributes('href')).toBeUndefined();
      Object.keys(linkProps).forEach(key => {
        expect(wrapper.attributes(key)).toBeUndefined();
      });
    });

    it('renders the inner text as provided', () => {
      expect(wrapper.text()).toBe(linkText);
    });
  });
});
