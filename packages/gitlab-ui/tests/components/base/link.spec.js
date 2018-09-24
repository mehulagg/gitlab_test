import { shallowMount } from '@vue/test-utils';
import Link from '../../../components/base/link.vue';

describe('link component', () => {
  const mountWithOptions = shallowMount.bind(null, Link);

  it('should have set the rel attribute with "noopener noreferrer" for target="blank"', () => {
    const link = mountWithOptions({
      propsData: {
        target: '_blank',
      }
    });

    expect(
      link.vm.relType
    ).toBe('noopener noreferrer');
  });

  describe('default settings', () => {
    let link;

    beforeEach(() => link = mountWithOptions({ }));

    it('should not have a set rel attribute', () => {
      expect(
        link.vm.relType
      ).toBe('');
    });

    it('should not have a target attribute', () => {
      expect(
        link.vm.$el.getAttribute('target')
      ).toBe(null);
    });
  });
});
