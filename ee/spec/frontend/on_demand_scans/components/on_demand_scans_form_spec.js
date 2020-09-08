import { merge } from 'lodash';
import { shallowMount } from '@vue/test-utils';
import { GlForm, GlSkeletonLoader } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import OnDemandScansProfileSelector from 'ee/on_demand_scans/components/on_demand_scans_profile_selector.vue';
import dastOnDemandScanCreate from 'ee/on_demand_scans/graphql/dast_on_demand_scan_create.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

const helpPagePath = `${TEST_HOST}/application_security/dast/index#on-demand-scans`;
const projectPath = 'group/project';
const defaultBranch = 'master';
const scannerProfilesLibraryPath = '/on_demand_scans/profiles#scanner-profiles';
const siteProfilesLibraryPath = '/on_demand_scans/profiles#site-profiles';
const newScannerProfilePath = '/on_demand_scans/profiles/dast_scanner_profile/new';
const newSiteProfilePath = `${TEST_HOST}/${projectPath}/-/on_demand_scans/profiles`;

const defaultProps = {
  helpPagePath,
  projectPath,
  defaultBranch,
};

const defaultMocks = {
  $apollo: {
    mutate: jest.fn(),
    queries: {
      scannerProfiles: {},
      siteProfiles: {},
    },
    addSmartQuery: jest.fn(),
  },
};

const scannerProfiles = [
  { id: 1, profileName: 'My first scanner profile', spiderTimeout: 5, targetTimeout: 10 },
  { id: 2, profileName: 'My second scanner profile', spiderTimeout: 20, targetTimeout: 150 },
];
const siteProfiles = [
  { id: 1, profileName: 'My first site profile', targetUrl: 'https://example.com' },
  { id: 2, profileName: 'My second site profile', targetUrl: 'https://foo.bar' },
];
const pipelineUrl = `${TEST_HOST}/${projectPath}/pipelines/123`;

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  redirectTo: jest.fn(),
}));

describe('OnDemandScansForm', () => {
  let wrapper;

  const findForm = () => wrapper.find(GlForm);
  const findByTestId = testId => wrapper.find(`[data-testid="${testId}"]`);
  const findAlert = () => findByTestId('on-demand-scan-error');
  const findCancelButton = () => findByTestId('on-demand-scan-cancel-button');

  const setFormData = async () => {
    const profileSelectors = wrapper.findAll(OnDemandScansProfileSelector);
    await profileSelectors.at(0).vm.$emit('set-profile', scannerProfiles[0].id);
    await profileSelectors.at(1).vm.$emit('set-profile', siteProfiles[0].id);
  };
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      OnDemandScansForm,
      merge(
        {},
        {
          propsData: defaultProps,
          mocks: defaultMocks,
          provide: {
            scannerProfilesLibraryPath,
            siteProfilesLibraryPath,
            newScannerProfilePath,
            newSiteProfilePath,
          },
        },
        options,
        {
          data() {
            return { ...options.data };
          },
        },
      ),
    );
  };
  const createComponent = wrapperFactory();

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders properly', () => {
    createComponent();
    expect(wrapper.html()).not.toBe('');
  });

  describe('submission', () => {
    beforeEach(() => {
      createComponent({
        data: {
          scannerProfiles,
          siteProfiles,
        },
      });
    });

    describe('on success', () => {
      beforeEach(async () => {
        jest
          .spyOn(wrapper.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl, errors: [] } } });
        await setFormData();
        await wrapper.vm.$nextTick();
        submitForm();
      });

      it('sets loading state', () => {
        expect(wrapper.vm.loading).toBe(true);
      });

      it('triggers GraphQL mutation', () => {
        expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
          mutation: dastOnDemandScanCreate,
          variables: {
            dastScannerProfileId: scannerProfiles[0].id,
            dastSiteProfileId: siteProfiles[0].id,
            fullPath: projectPath,
          },
        });
      });

      it('redirects to the URL provided in the response', () => {
        expect(redirectTo).toHaveBeenCalledWith(pipelineUrl);
      });

      it('does not show an alert', () => {
        expect(findAlert().exists()).toBe(false);
      });
    });

    describe('on top-level error', () => {
      beforeEach(() => {
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue();
        setFormData();
        submitForm();
      });

      it('resets loading state', () => {
        expect(wrapper.vm.loading).toBe(false);
      });

      it('shows an alert', () => {
        const alert = findAlert();
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toContain('Could not run the scan. Please try again.');
      });
    });

    describe('on errors as data', () => {
      const errors = ['error#1', 'error#2', 'error#3'];

      beforeEach(() => {
        jest
          .spyOn(wrapper.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl: null, errors } } });
        setFormData();
        submitForm();
      });

      it('resets loading state', () => {
        expect(wrapper.vm.loading).toBe(false);
      });

      it('shows an alert with the returned errors', () => {
        const alert = findAlert();

        expect(alert.exists()).toBe(true);
        errors.forEach(error => {
          expect(alert.text()).toContain(error);
        });
      });
    });
  });

  describe('cancel', () => {
    it('emits cancel event on click', () => {
      createComponent();
      jest.spyOn(wrapper.vm, '$emit');
      findCancelButton().vm.$emit('click');

      expect(wrapper.vm.$emit).toHaveBeenCalledWith('cancel');
    });
  });
});
