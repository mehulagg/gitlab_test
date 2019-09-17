import Vue from 'vue';
import '~/behaviors/markdown/render_gfm';
import { createStore } from '~/ide/stores';
import RightPane from '~/ide/components/panes/right.vue';
import { rightSidebarViews } from '~/ide/constants';
import { createComponentWithStore } from '../../../helpers/vue_mount_component_helper';

describe('IDE right pane', () => {
  let Component;
  let vm;

  beforeAll(() => {
    Component = Vue.extend(RightPane);
  });

  beforeEach(() => {
    const store = createStore();

    vm = createComponentWithStore(Component, store).$mount();
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('live preview', () => {
    it('renders live preview button', done => {
      Vue.set(vm.$store.state.entries, 'package.json', { name: 'package.json' });
      vm.$store.state.clientsidePreviewEnabled = true;

      vm.$nextTick(() => {
        expect(vm.$el.querySelector('button[aria-label="Live preview"]')).not.toBeNull();

        done();
      });
    });
  });
});
