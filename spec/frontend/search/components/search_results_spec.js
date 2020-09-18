import { shallowMount } from '@vue/test-utils';
import SearchResults from '~/search/components/search_results.vue';

describe('SearchResults', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(SearchResults);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findSearchResults = () => wrapper.find(SearchResults);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders scope results always', () => {
      expect(findSearchResults().exists()).toBe(true);
    });
  });
});
