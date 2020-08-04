import { shallowMount } from '@vue/test-utils';
import { GlDrawer } from '@gitlab/ui';
import BoardContentSidebar from 'ee_component/boards/components/board_content_sidebar.vue';
import store from '~/boards/stores';
import waitForPromises from 'helpers/wait_for_promises';

describe('ee/BoardContent', () => {
  let wrapper;
  let storeCopy;

  const createComponent = () => {
    wrapper = shallowMount(BoardContentSidebar, {
      store: storeCopy,
      provide: {
        glFeatures: {
          boardsWithSwimlanes: true,
        },
      },
    });
  };

  beforeEach(() => {
    storeCopy = store;
    storeCopy.state.isShowingEpicsSwimlanes = true;
    storeCopy.state.sidebarType = 'Issuable';
    storeCopy.state.activeId = 1;
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when boardsWithSwimlanes is on', () => {
    describe('when isShowingEpicsSwimlanes', () => {
      beforeEach(() => {
        createComponent();
      });

      afterEach(() => {
        storeCopy = store;
      });

      it('confirms we render GlDrawer', () => {
        expect(wrapper.find(GlDrawer).exists()).toBe(true);
      });

      it('applies an open attribute', () => {
        expect(wrapper.find(GlDrawer).props('open')).toBe(true);
      });

      describe('when we emit close', () => {
        it('hides GlDrawer', async () => {
          expect(wrapper.find(GlDrawer).props('open')).toBe(true);

          wrapper.find(GlDrawer).vm.$emit('close');

          await waitForPromises();

          expect(wrapper.find(GlDrawer).exists()).toBe(false);
        });
      });
    });
  });
});
