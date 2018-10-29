import { shallowMount } from '@vue/test-utils';
import LoadingIcon from '../../../components/base/loading_icon.vue';

describe('loading icon component', () => {
  const mountWithOptions = shallowMount.bind(null, LoadingIcon);

  describe('display', () => {
    it('should render as a block by default', () => {
      const component = mountWithOptions({});
      expect(component.vm.$el.tagName).toEqual('DIV');
    });

    it('should render inline using prop', () => {
      const component = mountWithOptions({
        propsData: {
          inline: true,
        },
      });
      expect(component.vm.$el.tagName).toEqual('SPAN');
    });
  });

  describe('css class', () => {
    it('should render fa-spin css class', () => {
      const component = mountWithOptions({});
      expect(component.vm.$el.querySelector('i').classList.contains('fa-spin')).toEqual(true);
    });

    it('should render fa-1x css class by default', () => {
      const component = mountWithOptions({});
      expect(component.vm.$el.querySelector('i').classList.contains('fa-1x')).toEqual(true);
    });

    it('should render fa-2x css class', () => {
      const component = mountWithOptions({
        propsData: {
          size: 2,
        },
      });
      expect(component.vm.$el.querySelector('i').classList.contains('fa-2x')).toEqual(true);
    });
  });

  describe('aria label', () => {
    it('should default to loading', () => {
      const component = mountWithOptions({});
      expect(component.vm.$el.querySelector('i').getAttribute('aria-label')).toEqual('Loading');
    });

    it('should change using prop', () => {
      const label = 'label';
      const component = mountWithOptions({
        propsData: {
          label,
        },
      });

      expect(component.vm.$el.querySelector('i').getAttribute('aria-label')).toEqual(label);
    });
  });
});
