import { shallowMount } from '@vue/test-utils';
import BoardContent from '~/boards/components/board_content.vue';
import BoardContentSidebar from 'ee_component/boards/components/board_content_sidebar.vue';
import store from '~/boards/stores';

describe('ee/BoardContent', () => {
  let wrapper;
  let storeCopy;
  const props = {
    lists: [],
    canAdminList: false,
    disabled: false,
    issueLinkBase: '',
    rootPath: '',
    boardId: '',
  };

  const createComponent = () => {
    wrapper = shallowMount(BoardContent, {
      store: storeCopy,
      propsData: props,
      provide: {
        glFeatures: {
          boardsWithSwimlanes: true,
        },
      },
      stubs: {
        'board-content-sidebar': BoardContentSidebar,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when isShowingEpicsSwimlanes', () => {
    beforeEach(() => {
      storeCopy = store;
      storeCopy.state.isShowingEpicsSwimlanes = true;

      createComponent();
    });

    afterEach(() => {
      storeCopy = store;
    });

    it('confirms we render BoardContentSidebar', () => {
      expect(wrapper.find(BoardContentSidebar).exists()).toBe(true);
    });
  });
});
