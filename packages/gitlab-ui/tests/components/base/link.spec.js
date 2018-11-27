import { shallowMount } from '@vue/test-utils';
import Link from '../../../components/base/link/link.vue';

describe('link component', () => {
  const mountWithOptions = shallowMount.bind(null, Link);

  describe('default settings', () => {
    let link;

    beforeEach(() => {
      link = mountWithOptions({});
    });

    it('should not have a set rel attribute', () => {
      expect(link.vm.relType).toBeUndefined();
    });

    it('should not have a target attribute', () => {
      expect(link.vm.$el.getAttribute('target')).toBe(null);
    });
  });

  describe('target blank', () => {
    it('should set noopener and noreferrer for hrefs in a different domain', () => {
      const mockedHostFunction = jest.fn(() => 'http://test.com');

      const link = mountWithOptions({
        propsData: {
          target: '_blank',
          href: 'http://example.com',
        },
        computed: {
          hostname: mockedHostFunction,
        },
      });

      expect(link.vm.relType).toBe('noopener noreferrer');
    });

    it('should keep rel attribute for hrefs in the same domain', () => {
      const linkWithRel = mountWithOptions({ attrs: { rel: 'noopener' } });

      expect(linkWithRel.vm.relType).toEqual('noopener');
    });
  });
});
