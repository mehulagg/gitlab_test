import { shallowMount } from '@vue/test-utils';
import SearchFilters from '~/search/components/search_filters.vue';

describe('SearchFilters', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(SearchFilters);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findSearchFilters = () => wrapper.find(SearchFilters);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders scope filters always', () => {
      expect(findSearchFilters().exists()).toBe(true);
    });
  });
});
