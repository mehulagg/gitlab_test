import { shallowMount } from '@vue/test-utils';
import LicenseComplianceApprovalActions from 'ee/approvals/components/license_compliance/approval_action.vue';

describe('EE Approvals LicenseCompliance ApprovalActions', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(LicenseComplianceApprovalActions, {
      propsData: {
        isLoading: false,
        isLicenseCheckActive: false,
        docsLink: 'http://foo.bar',
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders correctly', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
