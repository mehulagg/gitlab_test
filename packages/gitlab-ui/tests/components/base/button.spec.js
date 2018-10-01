import { shallowMount } from '@vue/test-utils';
import Button from '../../../components/base/button.vue';

describe('button component', () => {
  const mountWithOptions = shallowMount.bind(null, Button);

  it('should have set the rel attribute with "noopener noreferrer" for target="blank"', () => {
    const button = mountWithOptions({
      propsData: {
        target: '_blank',
        href: '#',
      }
    });

    expect(
      button.vm.relType
    ).toBe('noopener noreferrer');
  });

  describe('default settings', () => {
    let button;

    beforeEach(() => button = mountWithOptions({ }));

    it('should not have a set rel attribute', () => {
      expect(
        button.vm.relType
      ).toBe('');
    });

    it('should not have a target attribute', () => {
      expect(
        button.vm.$el.getAttribute('target')
      ).toBe(null);
    });

    it('should not have a href attribute', () => {
      expect(
        button.vm.$el.getAttribute('href')
      ).toBe(null);
    });
  });
});
