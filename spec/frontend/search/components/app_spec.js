import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import GlobalSearchApp from '~/search/components/app.vue';
import SearchForm from '~/search/components/search_form.vue';
import ScopeSelector from '~/search/components/scope_selector.vue';
import SearchFilters from '~/search/components/search_filters.vue';
import SearchResults from '~/search/components/search_results.vue';
import SearchLoading from '~/search/components/search_loading.vue';
import SearchEmptyState from '~/search/components/search_empty_state.vue';
import { MOCK_SEARCH_EMPTY_SVG_PATH } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GlobalSearchApp', () => {
  let wrapper;

  const defaultProps = {
    searchEmptySvgPath: MOCK_SEARCH_EMPTY_SVG_PATH,
  };

  const defaultState = {
    isLoading: false,
    results: [],
    query: {},
  };

  const createComponent = (props = {}, state = {}) => {
    const fakeStore = new Vuex.Store({
      state: {
        ...defaultState,
        ...state,
      },
    });

    wrapper = shallowMount(GlobalSearchApp, {
      localVue,
      store: fakeStore,
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findSearchForm = () => wrapper.find(SearchForm);
  const findScopeSelector = () => wrapper.find(ScopeSelector);
  const findSearchFilters = () => wrapper.find(SearchFilters);
  const findSearchResults = () => wrapper.find(SearchResults);
  const findSearchLoading = () => wrapper.find(SearchLoading);
  const findSearchEmptyState = () => wrapper.find(SearchEmptyState);

  describe.each`
    isLoading | results      | showLoader | showResults | showEmptyState
    ${true}   | ${[]}        | ${true}    | ${false}    | ${false}
    ${true}   | ${[1, 2, 3]} | ${true}    | ${false}    | ${false}
    ${false}  | ${[]}        | ${false}   | ${false}    | ${true}
    ${false}  | ${[1, 2, 3]} | ${false}   | ${true}     | ${false}
  `(`template`, ({ isLoading, results, showLoader, showResults, showEmptyState }) => {
    beforeEach(() => {
      createComponent({}, { isLoading, results });
    });

    describe(`when isLoading is ${isLoading} and results is ${results}`, () => {
      it('renders search form always', () => {
        expect(findSearchForm().exists()).toBe(true);
      });

      it('renders scope selector always', () => {
        expect(findScopeSelector().exists()).toBe(true);
      });

      it('renders search filters always', () => {
        expect(findSearchFilters().exists()).toBe(true);
      });

      it(`does ${showLoader ? '' : 'not'} render loader`, () => {
        expect(findSearchLoading().exists()).toBe(showLoader);
      });

      it(`does ${showResults ? '' : 'not'} render results`, () => {
        expect(findSearchResults().exists()).toBe(showResults);
      });

      it(`does ${showEmptyState ? '' : 'not'} render empty state`, () => {
        expect(findSearchEmptyState().exists()).toBe(showEmptyState);
      });
    });
  });
});
