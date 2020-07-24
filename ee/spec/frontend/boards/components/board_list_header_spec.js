import Vue from 'vue';
import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import BoardListHeader from 'ee/boards/components/board_list_header.vue';
import List from '~/boards/models/list';
import { ListType, inactiveId } from '~/boards/constants';
import sidebarEventHub from '~/sidebar/event_hub';
import { TEST_HOST } from 'helpers/test_constants';
import {
  useSmartResource,
  useFactoryArgs,
  useAxiosMockAdapter,
  useComponent,
} from 'helpers/resources';
import { listObj } from 'jest/boards/mock_data';

// board_promotion_state tries to mount on the real DOM,
// so we are mocking it in this test
jest.mock('ee/boards/components/board_promotion_state', () => ({}));

const localVue = createLocalVue();

localVue.use(Vuex);

describe('Board List Header Component', () => {
  const [axiosMock] = useAxiosMockAdapter();
  const [store] = useSmartResource(() => new Vuex.Store({ state: { activeId: inactiveId } }));
  const [wrapper, createComponent] = useComponent(
    ({
      listType = ListType.backlog,
      collapsed = false,
      withLocalStorage = true,
      isSwimlanesHeader = false,
    } = {}) => {
      const boardId = '1';

      const listMock = {
        ...listObj,
        list_type: listType,
        collapsed,
      };

      if (listType === ListType.assignee) {
        delete listMock.label;
        listMock.user = {};
      }

      // Making List reactive
      const list = Vue.observable(new List(listMock));

      if (withLocalStorage) {
        localStorage.setItem(
          `boards.${boardId}.${list.type}.${list.id}.expanded`,
          (!collapsed).toString(),
        );
      }

      return shallowMount(BoardListHeader, {
        store,
        localVue,
        propsData: {
          boardId,
          disabled: false,
          issueLinkBase: '/',
          rootPath: '/',
          list,
          isSwimlanesHeader,
        },
      });
    },
  );

  beforeEach(() => {
    window.gon = {};
    axiosMock.onGet(`${TEST_HOST}/lists/1/issues`).reply(200, { issues: [] });
    jest.spyOn(store, 'dispatch').mockImplementation();
  });

  afterEach(() => {
    localStorage.clear();
  });

  const findSettingsButton = () => wrapper.find({ ref: 'settingsBtn' });

  describe('Settings Button', () => {
    it.each(Object.values(ListType))(
      'when feature flag is off: does not render for List Type `%s`',
      listType => {
        window.gon = {
          features: {
            wipLimits: false,
          },
        };
        createComponent({ listType });

        expect(findSettingsButton().exists()).toBe(false);
      },
    );

    describe('when feature flag is on', () => {
      const hasSettings = [ListType.assignee, ListType.milestone, ListType.label];
      const hasNoSettings = [ListType.backlog, ListType.blank, ListType.closed, ListType.promotion];

      beforeEach(() => {
        window.gon = {
          features: {
            wipLimits: true,
          },
        };
      });

      it.each(hasSettings)('does render for List Type `%s`', listType => {
        createComponent({ listType });

        expect(findSettingsButton().exists()).toBe(true);
      });

      it.each(hasNoSettings)('does not render for List Type `%s`', listType => {
        createComponent({ listType });

        expect(findSettingsButton().exists()).toBe(false);
      });

      it('has a test for each list type', () => {
        Object.values(ListType).forEach(value => {
          expect([...hasSettings, ...hasNoSettings]).toContain(value);
        });
      });

      describe('emits sidebar.closeAll event on openSidebarSettings', () => {
        useFactoryArgs(wrapper, { listType: hasSettings[0] });

        beforeEach(() => {
          jest.spyOn(sidebarEventHub, '$emit');
        });

        it('emits event if no active List', () => {
          // Shares the same behavior for any settings-enabled List type
          wrapper.vm.openSidebarSettings();

          expect(sidebarEventHub.$emit).toHaveBeenCalledWith('sidebar.closeAll');
        });

        it('does not emits event when there is an active List', () => {
          store.state.activeId = listObj.id;

          wrapper.vm.openSidebarSettings();

          expect(sidebarEventHub.$emit).not.toHaveBeenCalled();
        });
      });
    });

    describe('Swimlanes header', () => {
      useFactoryArgs(wrapper, { isSwimlanesHeader: true, collapsed: true });

      it('when collapsed, it displays info icon', () => {
        expect(wrapper.contains('.board-header-collapsed-info-icon')).toBe(true);
      });
    });
  });
});
