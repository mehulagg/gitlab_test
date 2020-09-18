import { shallowMount } from '@vue/test-utils';
import SearchForm from '~/search/components/search_form.vue';

describe('SearchForm', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(SearchForm);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findSearchForm = () => wrapper.find(SearchForm);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders scope form always', () => {
      expect(findSearchForm().exists()).toBe(true);
    });
  });
});
