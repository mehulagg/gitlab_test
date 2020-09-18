import { shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';
import SearchEmptyState from '~/search/components/search_empty_state.vue';
import { MOCK_SEARCH_EMPTY_SVG_PATH } from '../mock_data';

describe('SearchEmptyState', () => {
  let wrapper;

  const defaultProps = {
    searchEmptySvgPath: MOCK_SEARCH_EMPTY_SVG_PATH,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(SearchEmptyState, {
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

  const findGlEmptyState = () => wrapper.find(GlEmptyState);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('GlEmptyState', () => {
      it('renders always', () => {
        expect(findGlEmptyState().exists()).toBe(true);
      });

      it('sets correct svg', () => {
        expect(findGlEmptyState().attributes('svgpath')).toBe(MOCK_SEARCH_EMPTY_SVG_PATH);
      });
    });
  });
});
