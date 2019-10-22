import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { GlEmptyState } from '@gitlab/ui';
import httpStatus from '~/lib/utils/http_status';
import Component from 'ee/analytics/code_analytics/components/app.vue';
import GroupsDropdownFilter from 'ee/analytics/shared/components/groups_dropdown_filter.vue';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import { DEFAULT_FILE_QUANTITY } from 'ee/analytics/code_analytics/constants';
import FileQuantityDropdown from 'ee/analytics/code_analytics/components/file_quantity_dropdown.vue';
import TreemapChart from 'ee/vue_shared/components/charts/treemap/treemap_chart.vue';
import { group, project, endpoint, codeHotspotsTransformedData } from '../mock_data';

const emptyStateTitle = 'Identify the most frequently changed files in your repository';
const emptyStateDescription =
  'Identify areas of the codebase associated with a lot of churn, which can indicate potential code hotspots.';
const emptyStateSvgPath = 'path/to/empty/state';

const noAccessSvgPath = 'path/to/no/access';
const noAccessStateTitle = "You don't have access to Code Analytics for this project";
const noAccessStateDescription =
  "Only 'Reporter' roles and above on tiers Premium / Silver and above can see Code Analytics.";

const localVue = createLocalVue();
localVue.use(Vuex);

const createComponent = (opts = {}) =>
  shallowMount(Component, {
    localVue,
    sync: false,
    propsData: {
      emptyStateSvgPath,
      noAccessSvgPath,
      endpoint,
    },
    ...opts,
  });

describe('Code Analytics component', () => {
  let wrapper;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    wrapper = createComponent();
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  describe('created', () => {
    const actionSpies = {
      setEndpoint: jest.fn(),
    };

    beforeEach(() => {
      wrapper = createComponent({ methods: actionSpies });
    });

    it('dispatches setEndpoint with the endpoint prop', () => {
      expect(actionSpies.setEndpoint).toHaveBeenCalledWith(endpoint);
    });
  });

  describe('mounted', () => {
    const actionSpies = {
      setSelectedFileQuantity: jest.fn(),
    };

    beforeEach(() => {
      wrapper = createComponent({ methods: actionSpies });
    });

    it('dispatches setSelectedFileQuantity with DEFAULT_FILE_QUANTITY', () => {
      expect(actionSpies.setSelectedFileQuantity).toHaveBeenCalledWith(DEFAULT_FILE_QUANTITY);
    });
  });

  describe('methods', () => {
    describe('onProjectSelect', () => {
      beforeEach(() => {
        wrapper.vm.$store.state.selectedGroup = group;
      });

      it('sets the project to null if no projects are submitted', () => {
        wrapper.vm.onProjectSelect([]);

        expect(wrapper.vm.$store.state.selectedProject).toBe(null);
      });

      it('sets the project correctly when submitted', () => {
        wrapper.vm.onProjectSelect([project]);

        expect(wrapper.vm.$store.state.selectedProject).toBe(project);
      });
    });
  });

  describe('displays the components as required', () => {
    describe('before a group has been selected', () => {
      beforeEach(() => {
        wrapper.vm.$store.state.selectedGroup = null;
      });

      it('displays an empty state', () => {
        const emptyState = wrapper.find(GlEmptyState);

        expect(emptyState.exists()).toBeTruthy();
        expect(emptyState.props('title')).toBe(emptyStateTitle);
        expect(emptyState.props('description')).toBe(emptyStateDescription);
        expect(emptyState.props('svgPath')).toBe(emptyStateSvgPath);
      });

      it('displays the groups filter', () => {
        expect(wrapper.find(GroupsDropdownFilter).exists()).toBeTruthy();
      });

      it('does not display the projects filter', () => {
        expect(wrapper.find(ProjectsDropdownFilter).exists()).toBeFalsy();
      });

      it('does not display the file quantity filter', () => {
        expect(wrapper.find(FileQuantityDropdown).exists()).toBeFalsy();
      });

      it('does not display the code hotspots chart', () => {
        expect(wrapper.find(TreemapChart).exists()).toBeFalsy();
      });
    });

    describe('after a group has been selected', () => {
      beforeEach(() => {
        wrapper.vm.$store.state.selectedGroup = group;
      });

      describe('with no project selected', () => {
        beforeEach(() => {
          wrapper.vm.$store.state.selectedProject = null;
        });

        it('displays an empty state', () => {
          const emptyState = wrapper.find(GlEmptyState);

          expect(emptyState.exists()).toBeTruthy();
          expect(emptyState.props('title')).toBe(emptyStateTitle);
          expect(emptyState.props('description')).toBe(emptyStateDescription);
          expect(emptyState.props('svgPath')).toBe(emptyStateSvgPath);
        });

        it('displays the groups filter', () => {
          expect(wrapper.find(GroupsDropdownFilter).exists()).toBeTruthy();
        });

        it('displays the projects filter', () => {
          expect(wrapper.find(ProjectsDropdownFilter).exists()).toBeTruthy();
        });

        it('does not display the file quantity filter', () => {
          expect(wrapper.find(FileQuantityDropdown).exists()).toBeFalsy();
        });

        it('does not display the code hotspots chart', () => {
          expect(wrapper.find(TreemapChart).exists()).toBeFalsy();
        });
      });

      describe('with a project selected', () => {
        beforeEach(() => {
          wrapper.vm.$store.state.selectedProject = project;
        });

        describe('with no access to the group / project', () => {
          beforeEach(() => {
            wrapper.vm.$store.state.errorCode = httpStatus.FORBIDDEN;
          });

          afterEach(() => {
            wrapper.vm.$store.state.errorCode = null;
          });

          it('displays the groups filter', () => {
            expect(wrapper.find(GroupsDropdownFilter).exists()).toBeTruthy();
          });

          it('displays the projects filter', () => {
            expect(wrapper.find(ProjectsDropdownFilter).exists()).toBeTruthy();
          });

          it('displays the file quantity filter', () => {
            expect(wrapper.find(FileQuantityDropdown).exists()).toBeTruthy();
          });

          it('displays the no access error message', () => {
            const noAccessState = wrapper.find(GlEmptyState);

            expect(noAccessState.exists()).toBeTruthy();
            expect(noAccessState.props('title')).toBe(noAccessStateTitle);
            expect(noAccessState.props('description')).toBe(noAccessStateDescription);
            expect(noAccessState.props('svgPath')).toBe(noAccessSvgPath);
          });
        });

        describe('with access to the group / project', () => {
          describe('with an error', () => {
            beforeEach(() => {
              wrapper.vm.$store.state.errorCode = httpStatus.NOT_FOUND;
            });

            afterEach(() => {
              wrapper.vm.$store.state.errorCode = null;
            });

            it('displays an empty state', () => {
              const emptyState = wrapper.find(GlEmptyState);

              expect(emptyState.exists()).toBeTruthy();
              expect(emptyState.props('title')).toBe(emptyStateTitle);
              expect(emptyState.props('description')).toBe(emptyStateDescription);
              expect(emptyState.props('svgPath')).toBe(emptyStateSvgPath);
            });

            it('displays the groups filter', () => {
              expect(wrapper.find(GroupsDropdownFilter).exists()).toBeTruthy();
            });

            it('displays the projects filter', () => {
              expect(wrapper.find(ProjectsDropdownFilter).exists()).toBeTruthy();
            });

            it('displays the file quantity filter', () => {
              expect(wrapper.find(FileQuantityDropdown).exists()).toBeTruthy();
            });
          });

          describe('with no error', () => {
            it('does not display an empty state', () => {
              expect(wrapper.find(GlEmptyState).exists()).toBeFalsy();
            });

            it('displays the groups filter', () => {
              expect(wrapper.find(GroupsDropdownFilter).exists()).toBeTruthy();
            });

            it('displays the projects filter', () => {
              expect(wrapper.find(ProjectsDropdownFilter).exists()).toBeTruthy();
            });

            it('displays the file quantity filter', () => {
              expect(wrapper.find(FileQuantityDropdown).exists()).toBeTruthy();
            });

            describe('with no code hotspots data', () => {
              it('does not display the code hotspots chart', () => {
                expect(wrapper.find(TreemapChart).exists()).toBeFalsy();
              });
            });

            describe('with code hotspots data', () => {
              beforeEach(() => {
                wrapper.vm.$store.state.codeHotspotsData = codeHotspotsTransformedData;
              });

              it('displays the code hotspots chart', () => {
                expect(wrapper.find(TreemapChart).exists()).toBeTruthy();
              });
            });
          });
        });
      });
    });
  });
});
