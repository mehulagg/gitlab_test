import Vue from 'vue';
import CveIdRequest from 'ee/sidebar/components/cve_id_request/cve_id_request_sidebar.vue';
import mountComponent from 'helpers/vue_mount_component_helper';

describe('CveIdRequest', () => {
  let initialData;
  let vm;

  const initCveIdRequest = () => {
    setFixtures(`
      <div>
        <div id="mock-container"></div>
      </div>
    `);

    initialData = {
      iid: 'test',
      fullPath: 'some/path',
      issueTitle: 'Issue Title',
    };

    const CveIdRequestComponent = Vue.extend({
      ...CveIdRequest,
      components: {
        ...CveIdRequest.components,
        transition: {
          // disable animations
          render(h) {
            return h('div', this.$slots.default);
          },
        },
      },
    });
    vm = mountComponent(CveIdRequestComponent, initialData, '#mock-container');
  };

  beforeEach(() => {
    initCveIdRequest();
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('Renders the main "Request CVE ID" button', () => {
    expect(vm.$el.querySelector('.js-cve-id-request-button')).not.toBeNull();
  });

  it('Renders the "help-button" by default', () => {
    expect(vm.$el.querySelector('.help-button')).not.toBeNull();
  });

  describe('Help Pane', () => {
    const helpButton = () => vm.$el.querySelector('.help-button');
    const closeHelpButton = () => vm.$el.querySelector('.close-help-button');
    const helpPane = () => vm.$el.querySelector('.cve-id-request-help-state');

    beforeEach(() => {
      initCveIdRequest();
      return vm.$nextTick();
    });

    it('should not show the "Help" pane by default', () => {
      expect(vm.showHelpState).toBe(false);
      expect(helpPane()).toBeNull();
    });

    it('should show the "Help" pane when help button is clicked', () => {
      helpButton().click();

      return vm.$nextTick().then(() => {
        expect(vm.showHelpState).toBe(true);

        // let animations run
        jest.advanceTimersByTime(500);

        expect(helpPane()).toBeVisible();
      });
    });

    it('should not show the "Help" pane when help button is clicked and then closed', done => {
      helpButton().click();

      Vue.nextTick()
        .then(() => closeHelpButton().click())
        .then(() => Vue.nextTick())
        .then(() => {
          expect(vm.showHelpState).toBe(false);
          expect(helpPane()).toBeNull();
        })
        .then(done)
        .catch(done.fail);
    });
  });
});
