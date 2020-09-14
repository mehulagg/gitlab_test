import merge from 'lodash/merge';
import VueApollo from 'vue-apollo';
import { within } from '@testing-library/dom';
import { createLocalVue, mount, shallowMount } from '@vue/test-utils';
import { createMockClient } from 'mock-apollo-client';
import { GlLoadingIcon } from '@gitlab/ui';
import waitForPromises from 'jest/helpers/wait_for_promises';
import DastSiteValidation from 'ee/dast_site_profiles_form/components/dast_site_validation.vue';
import dastSiteValidationCreateMutation from 'ee/dast_site_profiles_form/graphql/dast_site_validation_create.mutation.graphql';
import dastSiteValidationQuery from 'ee/dast_site_profiles_form/graphql/dast_site_validation.query.graphql';
import * as responses from 'ee_jest/dast_site_profiles_form/mock_data/apollo_mock';
import download from '~/lib/utils/downloader';

jest.mock('~/lib/utils/downloader');

const localVue = createLocalVue();
localVue.use(VueApollo);

const fullPath = 'group/project';
const targetUrl = 'https://example.com/';
const token = 'validation-token-123';

const defaultProps = {
  fullPath,
  targetUrl,
  token,
};

const defaultRequestHandlers = {
  dastSiteValidation: jest.fn().mockResolvedValue(responses.dastSiteValidation()),
  dastSiteValidationCreate: jest.fn().mockResolvedValue(responses.dastSiteValidationCreate()),
};

describe('DastSiteValidation', () => {
  let wrapper;
  let apolloProvider;
  let requestHandlers;

  const mockClientFactory = handlers => {
    const mockClient = createMockClient();

    requestHandlers = {
      ...defaultRequestHandlers,
      ...handlers,
    };

    mockClient.setRequestHandler(dastSiteValidationQuery, requestHandlers.dastSiteValidation);

    mockClient.setRequestHandler(
      dastSiteValidationCreateMutation,
      requestHandlers.dastSiteValidationCreate,
    );

    return mockClient;
  };

  const respondWith = handlers => {
    apolloProvider.defaultClient = mockClientFactory(handlers);
  };

  const componentFactory = (mountFn = shallowMount) => options => {
    apolloProvider = new VueApollo({
      defaultClient: mockClientFactory(),
    });

    wrapper = mountFn(
      DastSiteValidation,
      merge(
        {},
        {
          propsData: defaultProps,
        },
        options,
        {
          localVue,
          apolloProvider,
        },
      ),
    );
  };
  const createComponent = componentFactory();
  const createFullComponent = componentFactory(mount);

  const withinComponent = () => within(wrapper.element);
  const findDownloadButton = () =>
    wrapper.find('[data-testid="download-dast-text-file-validation-button"]');
  const findValidateButton = () => wrapper.find('[data-testid="validate-dast-site-button"]');
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findErrorMessage = () =>
    withinComponent().queryByText(
      /validation failed, please make sure that you follow the steps above with the choosen method./i,
    );

  afterEach(() => {
    wrapper.destroy();
  });

  describe('rendering', () => {
    beforeEach(() => {
      createFullComponent();
    });

    it('renders properly', () => {
      expect(wrapper.html()).not.toBe('');
    });

    it('renders a download button containing the token', () => {
      const downloadButton = withinComponent().getByRole('button', {
        name: 'Download validation text file',
      });
      expect(downloadButton).not.toBeNull();
    });

    it('renders an input group with the target URL prepended', () => {
      const inputGroup = withinComponent().getByRole('group', {
        name: 'Step 3 - Confirm text file location and validate',
      });
      expect(inputGroup).not.toBeNull();
      expect(inputGroup.textContent).toContain(targetUrl);
    });
  });

  describe('text file validation', () => {
    beforeEach(() => {
      createComponent();
    });

    it('clicking on the download button triggers a download of a text file containing the token', () => {
      findDownloadButton().vm.$emit('click');
      expect(download).toHaveBeenCalledWith({
        fileName: `GitLab-DAST-Site-Validation-${token}.txt`,
        fileData: btoa(token),
      });
    });
  });

  describe('validation', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('success', () => {
      beforeEach(() => {
        findValidateButton().vm.$emit('click');
      });

      it('while validating, shows a loading state', () => {
        expect(findLoadingIcon().exists()).toBe(true);
        expect(wrapper.text()).toContain('Validating...');
      });

      it('on success, emits success event', async () => {
        await waitForPromises();

        expect(wrapper.emitted('success')).toHaveLength(1);
      });
    });

    describe.each`
      errorKind            | errorResponse
      ${'top level error'} | ${() => Promise.reject(new Error('GraphQL Network Error'))}
      ${'errors as data'}  | ${() => Promise.resolve(responses.dastSiteValidationCreate(['error#1', 'error#2']))}
    `('$errorKind', ({ errorResponse }) => {
      beforeEach(() => {
        respondWith({
          dastSiteValidationCreate: errorResponse,
        });
      });

      it('on error, shows error state', async () => {
        expect(findErrorMessage()).toBe(null);

        findValidateButton().vm.$emit('click');

        await waitForPromises();

        expect(findErrorMessage()).not.toBe(null);
      });
    });
  });
});
