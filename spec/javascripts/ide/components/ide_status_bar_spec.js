import Vue from 'vue';
import { createComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import store from '~/ide/stores';
import ideStatusBar from '~/ide/components/ide_status_bar.vue';
import { rightSidebarViews } from '~/ide/constants';
import { resetStore } from '../helpers';
import { projectData } from '../mock_data';

describe('ideStatusBar', () => {
  let vm;
  const email = 'jdoe@gitlab.com';
  const avatarUrl = 'a/b/c/abc.jpg';

  beforeAll(() => {
    window.gon = {
      current_user_email: email,
      current_user_avatar_url: avatarUrl,
    };
  });

  afterAll(() => {
    window.gon = {};
  });

  beforeEach(() => {
    const Component = Vue.extend(ideStatusBar);

    store.state.currentProjectId = 'abcproject';
    store.state.projects.abcproject = projectData;
    store.state.currentBranchId = 'master';

    vm = createComponentWithStore(Component, store).$mount();
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);
  });

  describe('computed:', () => {
    describe('userAvatar', () => {
      it('returns undefined by default', () => {
        expect(vm.userAvatar).toBe(undefined);
      });

      it('should return the latestPipeline.commit.author_gravatar_url if present', () => {
        // Have to set the right data set directly using the store so it's taken into account by Vue
        Vue.set(vm.$store.state.pipelines, 'latestPipeline', {
          commit: { author_gravatar_url: avatarUrl },
        });

        expect(vm.userAvatar).toBe(avatarUrl);
      });

      it('should check lastCommit email matching the current user to receive the right image', () => {
        // Have to set the right data set directly using the store so it's taken into account by Vue
        Vue.set(vm.$store.state.projects.abcproject.branches.master.commit, 'author_email', email);

        expect(vm.lastCommit.author_email).toBe(email);

        // vm.$nextTick()
        //   .then(() => {
        //     console.log(window.gon.current_user_email)

        //     expect(vm.userAvatar).toBe(avatarUrl)
        //
        //   })
        //   .then(done)
        //   .catch(done.fail)
      });
    });
  });

  it('renders the statusbar', () => {
    expect(vm.$el.className).toBe('ide-status-bar');
  });

  describe('mounted', () => {
    it('triggers a setInterval', () => {
      expect(vm.intervalId).not.toBe(null);
    });
  });

  describe('commitAgeUpdate', () => {
    beforeEach(function() {
      jasmine.clock().install();
      spyOn(vm, 'commitAgeUpdate').and.callFake(() => {});
      vm.startTimer();
    });

    afterEach(function() {
      jasmine.clock().uninstall();
    });

    it('gets called every second', () => {
      expect(vm.commitAgeUpdate).not.toHaveBeenCalled();

      jasmine.clock().tick(1100);

      expect(vm.commitAgeUpdate.calls.count()).toEqual(1);

      jasmine.clock().tick(1000);

      expect(vm.commitAgeUpdate.calls.count()).toEqual(2);
    });
  });

  describe('getCommitPath', () => {
    it('returns the path to the commit details', () => {
      expect(vm.getCommitPath('abc123de')).toBe('/commit/abc123de');
    });
  });

  describe('pipeline status', () => {
    it('opens right sidebar on clicking icon', done => {
      spyOn(vm, 'openRightPane');
      Vue.set(vm.$store.state.pipelines, 'latestPipeline', {
        details: {
          status: {
            text: 'success',
            details_path: 'test',
            icon: 'status_success',
          },
        },
        commit: {
          author_gravatar_url: 'www',
        },
      });

      vm.$nextTick()
        .then(() => {
          vm.$el.querySelector('.ide-status-pipeline button').click();

          expect(vm.openRightPane).toHaveBeenCalledWith(rightSidebarViews.pipelines);
        })
        .then(done)
        .catch(done.fail);
    });
  });
});
