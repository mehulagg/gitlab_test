import { createLocalVue, shallowMount } from '@vue/test-utils';
import { WARNING } from 'ee/dependencies/constants';
import DependencyListAlert from 'ee/dependencies/components/dependency_list_alert.vue';

describe('DependencyListAlert component', () => {
  let wrapper;

  const factory = (props = {}) => {
    const localVue = createLocalVue();

    wrapper = shallowMount(localVue.extend(DependencyListAlert), {
      localVue,
      sync: false,
      propsData: { ...props },
      slots: {
        default: '<p>foo <span>bar</span></p>',
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('given no type prop', () => {
    beforeEach(() => {
      factory();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('given the warning type prop', () => {
    beforeEach(() => {
      factory({ type: WARNING });
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('clicking on the close button', () => {
    beforeEach(() => {
      factory();
      wrapper.find('.js-close').trigger('click');
      return wrapper.vm.$nextTick();
    });

    it('renders nothing', () => {
      expect(wrapper.isEmpty()).toBe(true);
    });
  });
});
