import { shallowMount } from '@vue/test-utils';
import { GlNewDropdown, GlNewDropdownItem } from '@gitlab/ui';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
// import currentIterationQuery from 'ee/sidebar/components/queries/issue_iteration.query.graphql';
// import setIterationOnIssue from 'ee/sidebar/components/queries/set_iteration_on_issue.mutation.graphql';
// import groupIterationssQuery from 'ee/sidebar/components/queries/group_iterations.query.graphql';

describe('IterationSelect', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(IterationSelect, {
      propsData: {
        canEdit: false,
        groupPath: '',
        projectPath: '',
        issueIid: '',
      },
      mocks: {
        $apollo: {
          // how to test that on mount, data has been set from query.
          queries: {
            iterations: {
              group: { iterations: { nodes: [] } },
            },
            currentIteration: ''
          },
          // currentIteration: {
          //   query: currentIterationQuery,
          //   variables: {},
          //   update: () => {},
          // },
          // iterations: {
          //   query: groupIterationssQuery,
          //   variables: {},
          //   update: () => {},
          // },
          mutate: () => {},
        }
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when a user can edit', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('when user is editing', () => {
      it('shows GlNewDropdown', () => {
        // need to mock data().
        expect(wrapper.find(GlNewDropdownItem).exists()).toBe(true);
      });
    });
  });
});
