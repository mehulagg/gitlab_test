import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import List from '~/ide/components/merge_requests/list.vue';
import Item from '~/ide/components/merge_requests/item.vue';
import TokenedInput from '~/ide/components/shared/tokened_input.vue';
import { __ } from '~/locale';
import { GlLoadingIcon } from '@gitlab/ui';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('IDE merge requests list', () => {
  let wrapper;

  const fetchMergeRequestsMock = jest.fn();

  const findSearchTypeButtons = () => wrapper.findAll('button');

  const createComponent = (state = {}) => {
    const { mergeRequests, ...restOfState } = state;
    const fakeStore = new Vuex.Store({
      state: {
        currentMergeRequestId: '1',
        currentProjectId: 'project/master',
        ...restOfState,
      },
      modules: {
        mergeRequests: {
          namespaced: true,
          state: {
            isLoading: false,
            mergeRequests: [],
            ...mergeRequests,
          },
          actions: {
            fetchMergeRequests: fetchMergeRequestsMock,
          },
        },
      },
    });

    wrapper = shallowMount(List, {
      store: fakeStore,
      localVue,
      sync: false,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('calls fetch on mounted', () => {
    createComponent();
    expect(fetchMergeRequests).toHaveBeenCalledWith({
      search: '',
      type: '',
    });
  });

  it('renders loading icon when merge request is loading', () => {
    createComponent({ mergeRequests: { isLoading: true } });
    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
  });

  it('renders no search results text when search is not empty', () => {
    createComponent({ mergeRequests: { mergeRequests: [] } });
    const input = wrapper.find(TokenedInput);
    input.vm.$emit('input', 'something');
    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.text()).toContain('No merge requests found');
    });
  });

  it('clicking on search type, sets currentSearchType and loads merge requests', () => {
    createComponent({ mergeRequests: { mergeRequests: [] } });
    const input = wrapper.find(TokenedInput);
    input.vm.$emit('focus');
    return wrapper.vm
      .$nextTick()
      .then(() => {
        findSearchTypeButtons()
          .at(0)
          .trigger('click');
        return wrapper.vm.$nextTick();
      })
      .then(() => {
        expect(fetchMergeRequestsMock).toHaveBeenCalledWith(
          expect.any(Object),
          {
            type: wrapper.vm.$options.searchTypes[0].type,
            search: '',
          },
          undefined,
        );
      });
  });

  describe('with merge requests', () => {
    let defaultStateWithMergeRequests;

    beforeAll(() => {
      // We can't import mock_data directly as it relies on gl global
      // We can get rid of this when our Karma -> Jest migration will be complete
      global.gl = {
        TEST_HOST: 'https://some.host',
      };
      return import('../../../../javascripts/ide/mock_data').then(({ mergeRequests }) => {
        defaultStateWithMergeRequests = {
          mergeRequests: {
            isLoading: false,
            mergeRequests: [
              { ...mergeRequests[0], projectPathWithNamespace: 'gitlab-org/gitlab-foss' },
            ],
          },
        };
      });
    });

    afterAll(() => {
      delete global.gl;
    });

    it('renders list', () => {
      createComponent(defaultStateWithMergeRequests);

      expect(wrapper.findAll(Item).length).toBe(1);
      expect(wrapper.find(Item).props('item')).toBe(
        defaultStateWithMergeRequests.mergeRequests.mergeRequests[0],
      );
    });

    describe('when searching merge requests', () => {
      it('calls `loadMergeRequests` on input in search field', () => {
        createComponent(defaultStateWithMergeRequests);
        const input = wrapper.find(TokenedInput);
        input.vm.$emit('input', 'something');
        fetchMergeRequestsMock.mockClear();

        jest.runAllTimers();
        return wrapper.vm.$nextTick().then(() => {
          expect(fetchMergeRequestsMock).toHaveBeenCalled();
        });
      });
    });
  });

  describe('on search focus', () => {
    it('shows search types if has no search value', () => {
      createComponent({ mergeRequests: { mergeRequests: [] } });
      const input = wrapper.find(TokenedInput);
      input.vm.$emit('focus');

      return wrapper.vm.$nextTick().then(() => {
        const buttons = findSearchTypeButtons();
        expect(
          wrapper.vm.$options.searchTypes.every(
            ({ label }) => buttons.filter(w => w.text() === label).length > 0,
          ),
        ).toBe(true);
      });
    });

    it('does not show search types, if already has search value', () => {
      createComponent({ mergeRequests: { mergeRequests: [] } });
      const input = wrapper.find(TokenedInput);
      input.vm.$emit('focus');
      input.vm.$emit('input', 'something');
      return wrapper.vm.$nextTick().then(() => {
        expect(findSearchTypeButtons().exists()).toBe(false);
      });
    });

    it('does not show search types, if already has a search type', () => {
      createComponent({ mergeRequests: { mergeRequests: [] } });
      const input = wrapper.find(TokenedInput);
      input.vm.$emit('focus');
      return wrapper.vm
        .$nextTick()
        .then(() => {
          findSearchTypeButtons()
            .at(0)
            .trigger('click');
          return wrapper.vm.$nextTick();
        })
        .then(() => {
          expect(findSearchTypeButtons().exists()).toBe(false);
        });
    });
  });
});
