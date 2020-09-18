import { shallowMount } from '@vue/test-utils';
import { GlCard, GlSkeletonLoader } from '@gitlab/ui';
import SearchLoading from '~/search/components/search_loading.vue';

describe('SearchLoading', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(SearchLoading);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlCard = () => wrapper.find(GlCard);
  const findGlSkeletonLoader = () => wrapper.find(GlSkeletonLoader);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders card container always', () => {
      expect(findGlCard().exists()).toBe(true);
    });

    it('renders nested loader always', () => {
      expect(findGlSkeletonLoader().exists()).toBe(true);
    });
  });
});
