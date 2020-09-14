import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import Api from 'ee/api';
import store from 'ee/feature_flags/store';
import FeatureFlagsComponent from 'ee/feature_flags/components/feature_flags.vue';
import FeatureFlagsTable from 'ee/feature_flags/components/feature_flags_table.vue';
import UserListsTable from 'ee/feature_flags/components/user_lists_table.vue';
import ConfigureFeatureFlagsModal from 'ee/feature_flags/components/configure_feature_flags_modal.vue';
import { FEATURE_FLAG_SCOPE, USER_LIST_SCOPE } from 'ee/feature_flags/constants';
import { TEST_HOST } from 'spec/test_constants';
import NavigationTabs from '~/vue_shared/components/navigation_tabs.vue';
import TablePagination from '~/vue_shared/components/pagination/table_pagination.vue';
import axios from '~/lib/utils/axios_utils';
import { getRequestData, userList } from '../mock_data';

describe('Feature flags', () => {
  const mockData = {
    endpoint: `${TEST_HOST}/endpoint.json`,
    csrfToken: 'testToken',
    errorStateSvgPath: '/assets/illustrations/feature_flag.svg',
    featureFlagsHelpPagePath: '/help/feature-flags',
    featureFlagsClientLibrariesHelpPagePath: '/help/feature-flags#unleash-clients',
    featureFlagsClientExampleHelpPagePath: '/help/feature-flags#client-example',
    unleashApiUrl: `${TEST_HOST}/api/unleash`,
    unleashApiInstanceId: 'oP6sCNRqtRHmpy1gw2-F',
    canUserConfigure: true,
    canUserRotateToken: true,
    newFeatureFlagPath: 'feature-flags/new',
    newUserListPath: '/user-list/new',
    projectId: '8',
  };

  let wrapper;
  let mock;

  const factory = (propsData = mockData, fn = shallowMount) => {
    wrapper = fn(FeatureFlagsComponent, {
      propsData,
      provide: {
        projectName: 'fakeProjectName',
      },
    });
  };

  const configureButton = () => wrapper.find('[data-testid="ff-configure-button"]');
  const newButton = () => wrapper.find('[data-testid="ff-new-button"]');
  const newUserListButton = () => wrapper.find('[data-testid="ff-new-list-button"]');

  beforeEach(() => {
    mock = new MockAdapter(axios);
    jest.spyOn(store, 'dispatch');
    jest.spyOn(Api, 'fetchFeatureFlagUserLists').mockResolvedValue({
      data: [userList],
      headers: {
        'x-next-page': '2',
        'x-page': '1',
        'X-Per-Page': '8',
        'X-Prev-Page': '',
        'X-TOTAL': '40',
        'X-Total-Pages': '5',
      },
    });
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  describe('without permissions', () => {
    const propsData = {
      endpoint: `${TEST_HOST}/endpoint.json`,
      csrfToken: 'testToken',
      errorStateSvgPath: '/assets/illustrations/feature_flag.svg',
      featureFlagsHelpPagePath: '/help/feature-flags',
      canUserConfigure: false,
      canUserRotateToken: false,
      featureFlagsClientLibrariesHelpPagePath: '/help/feature-flags#unleash-clients',
      featureFlagsClientExampleHelpPagePath: '/help/feature-flags#client-example',
      unleashApiUrl: `${TEST_HOST}/api/unleash`,
      unleashApiInstanceId: 'oP6sCNRqtRHmpy1gw2-F',
      projectId: '8',
    };

    beforeEach(done => {
      mock
        .onGet(`${TEST_HOST}/endpoint.json`, { params: { scope: FEATURE_FLAG_SCOPE, page: '1' } })
        .reply(200, getRequestData, {});

      factory(propsData);

      setImmediate(() => {
        done();
      });
    });

    it('does not render configure button', () => {
      expect(configureButton().exists()).toBe(false);
    });

    it('does not render new feature flag button', () => {
      expect(newButton().exists()).toBe(false);
    });

    it('does not render new user list button', () => {
      expect(newUserListButton().exists()).toBe(false);
    });
  });

  describe('loading state', () => {
    it('renders a loading icon', () => {
      mock
        .onGet(`${TEST_HOST}/endpoint.json`, { params: { scope: FEATURE_FLAG_SCOPE, page: '1' } })
        .replyOnce(200, getRequestData, {});

      factory();

      const loadingElement = wrapper.find(GlLoadingIcon);

      expect(loadingElement.exists()).toBe(true);
      expect(loadingElement.props('label')).toEqual('Loading feature flags');
    });
  });

  describe('successful request', () => {
    describe('without feature flags', () => {
      let emptyState;

      beforeEach(done => {
        mock
          .onGet(mockData.endpoint, { params: { scope: FEATURE_FLAG_SCOPE, page: '1' } })
          .replyOnce(
            200,
            {
              feature_flags: [],
              count: {
                all: 0,
                enabled: 0,
                disabled: 0,
              },
            },
            {},
          );

        factory();

        setImmediate(() => {
          emptyState = wrapper.find(GlEmptyState);
          done();
        });
      });

      it('should render the empty state', () => {
        expect(wrapper.find(GlEmptyState).exists()).toBe(true);
      });

      it('renders configure button', () => {
        expect(configureButton().exists()).toBe(true);
      });

      it('renders new feature flag button', () => {
        expect(newButton().exists()).toBe(true);
      });

      it('renders new user list button', () => {
        expect(newUserListButton().exists()).toBe(true);
        expect(newUserListButton().attributes('href')).toBe('/user-list/new');
      });

      describe('in feature flags tab', () => {
        it('renders generic title', () => {
          expect(emptyState.props('title')).toEqual('Get started with feature flags');
        });
      });
    });

    describe('with paginated feature flags', () => {
      beforeEach(done => {
        mock
          .onGet(mockData.endpoint, { params: { scope: FEATURE_FLAG_SCOPE, page: '1' } })
          .replyOnce(200, getRequestData, {
            'x-next-page': '2',
            'x-page': '1',
            'X-Per-Page': '2',
            'X-Prev-Page': '',
            'X-TOTAL': '37',
            'X-Total-Pages': '5',
          });

        factory();
        setImmediate(() => {
          done();
        });
      });

      it('should render a table with feature flags', () => {
        const table = wrapper.find(FeatureFlagsTable);
        expect(table.exists()).toBe(true);
        expect(table.props(FEATURE_FLAG_SCOPE)).toEqual(
          expect.arrayContaining([
            expect.objectContaining({
              name: getRequestData.feature_flags[0].name,
              description: getRequestData.feature_flags[0].description,
            }),
          ]),
        );
      });

      it('should toggle a flag when receiving the toggle-flag event', () => {
        const table = wrapper.find(FeatureFlagsTable);

        const [flag] = table.props(FEATURE_FLAG_SCOPE);
        table.vm.$emit('toggle-flag', flag);

        expect(store.dispatch).toHaveBeenCalledWith('index/toggleFeatureFlag', flag);
      });

      it('renders configure button', () => {
        expect(configureButton().exists()).toBe(true);
      });

      it('renders new feature flag button', () => {
        expect(newButton().exists()).toBe(true);
      });

      it('renders new user list button', () => {
        expect(newUserListButton().exists()).toBe(true);
        expect(newUserListButton().attributes('href')).toBe('/user-list/new');
      });

      describe('pagination', () => {
        it('should render pagination', () => {
          expect(wrapper.find(TablePagination).exists()).toBe(true);
        });

        it('should make an API request when page is clicked', () => {
          jest.spyOn(wrapper.vm, 'updateFeatureFlagOptions');
          wrapper.find(TablePagination).vm.change(4);

          expect(wrapper.vm.updateFeatureFlagOptions).toHaveBeenCalledWith({
            scope: FEATURE_FLAG_SCOPE,
            page: '4',
          });
        });

        it('should make an API request when using tabs', () => {
          jest.spyOn(wrapper.vm, 'updateFeatureFlagOptions');
          wrapper.find(NavigationTabs).vm.$emit('onChangeTab', USER_LIST_SCOPE);

          expect(wrapper.vm.updateFeatureFlagOptions).toHaveBeenCalledWith({
            scope: USER_LIST_SCOPE,
            page: '1',
          });
        });
      });
    });

    describe('in user lists tab', () => {
      beforeEach(done => {
        factory();

        setImmediate(() => {
          done();
        });
      });
      beforeEach(() => {
        wrapper.find(NavigationTabs).vm.$emit('onChangeTab', USER_LIST_SCOPE);
        return wrapper.vm.$nextTick();
      });

      it('should display the user list table', () => {
        expect(wrapper.find(UserListsTable).exists()).toBe(true);
      });

      it('should set the user lists to display', () => {
        expect(wrapper.find(UserListsTable).props('userLists')).toEqual([userList]);
      });
    });
  });

  describe('unsuccessful request', () => {
    beforeEach(done => {
      mock
        .onGet(mockData.endpoint, { params: { scope: FEATURE_FLAG_SCOPE, page: '1' } })
        .replyOnce(500, {});
      Api.fetchFeatureFlagUserLists.mockRejectedValueOnce();

      factory();

      setImmediate(() => {
        done();
      });
    });

    it('should render error state', () => {
      const emptyState = wrapper.find(GlEmptyState);
      expect(emptyState.props('title')).toEqual('There was an error fetching the feature flags.');
      expect(emptyState.props('description')).toEqual(
        'Try again in a few moments or contact your support team.',
      );
    });

    it('renders configure button', () => {
      expect(configureButton().exists()).toBe(true);
    });

    it('renders new feature flag button', () => {
      expect(newButton().exists()).toBe(true);
    });

    it('renders new user list button', () => {
      expect(newUserListButton().exists()).toBe(true);
      expect(newUserListButton().attributes('href')).toBe('/user-list/new');
    });
  });

  describe('rotate instance id', () => {
    beforeEach(done => {
      mock
        .onGet(`${TEST_HOST}/endpoint.json`, { params: { scope: FEATURE_FLAG_SCOPE, page: '1' } })
        .reply(200, getRequestData, {});
      factory();

      setImmediate(() => {
        done();
      });
    });

    it('should fire the rotate action when a `token` event is received', () => {
      const actionSpy = jest.spyOn(wrapper.vm, 'rotateInstanceId');
      const modal = wrapper.find(ConfigureFeatureFlagsModal);
      modal.vm.$emit('token');

      expect(actionSpy).toHaveBeenCalled();
    });
  });
});
