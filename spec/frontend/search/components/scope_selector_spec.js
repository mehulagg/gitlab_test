import { shallowMount } from '@vue/test-utils';
import ScopeSelector from '~/search/components/scope_selector.vue';

describe('ScopeSelector', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(ScopeSelector);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findScopeSelector = () => wrapper.find(ScopeSelector);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders scope selector always', () => {
      expect(findScopeSelector().exists()).toBe(true);
    });
  });
});
