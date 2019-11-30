import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import LastCommit from '~/repository/components/last_commit.vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';

let wrapper;

function createCommitData(data = {}) {
  return {
    sha: '123456789',
    title: 'Commit title',
    message: 'Commit message',
    webUrl: 'https://test.com/commit/123',
    authoredDate: '2019-01-01',
    author: {
      name: 'Test',
      avatarUrl: 'https://test.com',
      webUrl: 'https://test.com/test',
    },
    pipeline: {
      detailedStatus: {
        detailsPath: 'https://test.com/pipeline',
        icon: 'failed',
        tooltip: 'failed',
        text: 'failed',
        group: {},
      },
    },
    ...data,
  };
}

function factory(commit = createCommitData(), loading = false) {
  wrapper = shallowMount(LastCommit, {
    mocks: {
      $apollo: {
        queries: {
          commit: {
            loading: true,
          },
        },
      },
    },
    sync: false,
    attachToDocument: true,
  });
  wrapper.setData({ commit });
  wrapper.vm.$apollo.queries.commit.loading = loading;
}

describe('Repository last commit component', () => {
  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    loading  | label
    ${true}  | ${'shows'}
    ${false} | ${'hides'}
  `('$label when loading icon $loading is true', ({ loading }) => {
    factory(createCommitData(), loading);

    return wrapper.vm.$nextTick(() => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(loading);
    });
  });

  it('renders commit widget', () => {
    factory();

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders short commit ID', async () => {
    factory();

    await wrapper.vm.$nextTick();

    expect(wrapper.find('.label-monospace').text()).toEqual('12345678');
  });

  it('hides pipeline components when pipeline does not exist', () => {
    factory(createCommitData({ pipeline: null }));

    expect(wrapper.find('.js-commit-pipeline').exists()).toBe(false);
  });

  it('renders pipeline components', async () => {
    factory();

    await wrapper.vm.$nextTick();

    expect(wrapper.find('.js-commit-pipeline').exists()).toBe(true);
  });

  it('hides author component when author does not exist', () => {
    factory(createCommitData({ author: null }));

    expect(wrapper.find('.js-user-link').exists()).toBe(false);
    expect(wrapper.find(UserAvatarLink).exists()).toBe(false);
  });

  it('does not render description expander when description is null', () => {
    factory(createCommitData({ description: null }));

    expect(wrapper.find('.text-expander').exists()).toBe(false);
    expect(wrapper.find('.commit-row-description').exists()).toBe(false);
  });

  it('expands commit description when clicking expander', async () => {
    factory(createCommitData({ description: 'Test description' }));

    await wrapper.vm.$nextTick();

    wrapper.find('.text-expander').trigger('click');

    await wrapper.vm.$nextTick();

    expect(wrapper.find('.commit-row-description').isVisible()).toBe(true);
    expect(wrapper.find('.text-expander').classes('open')).toBe(true);
  });

  it('renders the signature HTML as returned by the backend', () => {
    factory(createCommitData({ signatureHtml: '<button>Verified</button>' }));

    expect(wrapper.element).toMatchSnapshot();
  });
});
