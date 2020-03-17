import { shallowMount } from '@vue/test-utils';
import FirstClassProjectSecurityDashboard from 'ee/security_dashboard/components/first_class_project_security_dashboard.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import ProjectVulnerabilitiesApp from 'ee/vulnerabilities/components/project_vulnerabilities_app.vue';
import ReportsNotConfigured from 'ee/security_dashboard/components/empty_states/reports_not_configured.vue';

const props = {
  dashboardDocumentation: '/help/docs',
  emptyStateSvgPath: '/svgs/empty/svg',
  projectFullPath: '/group/project',
  securityDashboardHelpPath: '/security/dashboard/help-path',
};
const filters = { foo: 'bar' };

describe('First class Project Security Dashboard component', () => {
  let wrapper;

  const findFilters = () => wrapper.find(Filters);
  const findVulnerabilities = () => wrapper.find(ProjectVulnerabilitiesApp);
  const findUnconfiguredState = () => wrapper.find(ReportsNotConfigured);

  const createComponent = options => {
    wrapper = shallowMount(FirstClassProjectSecurityDashboard, {
      propsData: {
        ...props,
        ...options.props,
      },
      stubs: { SecurityDashboardLayout },
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on render when pipeline has data', () => {
    beforeEach(() => {
      createComponent({ props: { hasPipelineData: true } });
    });

    it('should render the vulnerabilities', () => {
      expect(findVulnerabilities().exists()).toBe(true);
    });

    it('should pass down the %s prop to the vulnerabilities', () => {
      expect(findVulnerabilities().props('dashboardDocumentation')).toBe(
        props.dashboardDocumentation,
      );
      expect(findVulnerabilities().props('emptyStateSvgPath')).toBe(props.emptyStateSvgPath);
      expect(findVulnerabilities().props('projectFullPath')).toBe(props.projectFullPath);
    });

    it('should render the filters component', () => {
      expect(findFilters().exists()).toBe(true);
    });

    it('does not display the unconfigured state', () => {
      expect(findUnconfiguredState().exists()).toBe(false);
    });
  });

  describe('with filter data', () => {
    beforeEach(() => {
      createComponent({
        props: {
          hasPipelineData: true,
        },
        data() {
          return { filters };
        },
      });
    });

    it('should pass the filter data down to the vulnerabilities', () => {
      expect(findVulnerabilities().props().filters).toEqual(filters);
    });
  });

  describe('when pipeline has no data', () => {
    beforeEach(() => {
      createComponent({
        props: {
          hasPipelineData: false,
        },
      });
    });

    it('displays the unconfigured state', () => {
      expect(findUnconfiguredState().exists()).toBe(true);
    });
  });
});
