import { mount } from '@vue/test-utils';
import * as flash from '~/flash';
import * as urlUtil from '~/lib/utils/url_utility';
import MRWidgetService from '~/vue_merge_request_widget/services/mr_widget_service';
import DeploymentActions from '~/vue_merge_request_widget/components/deployment/deployment_actions.vue';
import {
  CREATED,
  MANUAL_DEPLOY,
  FAILED,
  DEPLOYING,
  REDEPLOYING,
  STOPPING,
} from '~/vue_merge_request_widget/components/deployment/constants';
import {
  actionButtonMocks,
  deploymentMockData,
  playDetails,
  retryDetails,
} from './deployment_mock_data';

describe('DeploymentAction component', () => {
  let wrapper;

  const factory = (options = {}) => {
    // This destroys any wrappers created before a nested call to factory reassigns it
    if (wrapper && wrapper.destroy) {
      wrapper.destroy();
    }

    wrapper = mount(DeploymentActions, {
      ...options,
    });
  };

  const findStopButton = () => wrapper.find('.js-stop-env');
  const findDeployButton = () => wrapper.find('.js-manual-deploy-action');
  const findRedeployButton = () => wrapper.find('.js-manual-redeploy-action');

  beforeEach(() => {
    factory({
      propsData: {
        computedDeploymentStatus: CREATED,
        deployment: deploymentMockData,
        showVisualReviewApp: false,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('actions do not appear when conditions are unmet', () => {
    describe('when there is no stop_url', () => {
      beforeEach(() => {
        factory({
          propsData: {
            computedDeploymentStatus: CREATED,
            deployment: {
              ...deploymentMockData,
              stop_url: null,
            },
            showVisualReviewApp: false,
          },
        });
      });

      it('the stop button does not appear', () => {
        expect(findStopButton().exists()).toBe(false);
      });
    });

    describe('when there is no play_path in details', () => {
      it('the manual deploy button does not appear', () => {
        expect(findDeployButton().exists()).toBe(false);
      });
    });

    describe('when there is no retry_path in details', () => {
      it('the manual redeploy button does not appear', () => {
        expect(findRedeployButton().exists()).toBe(false);
      });
    });
  });

  describe('when conditions are met', () => {
    describe.each`
      configConst    | computedDeploymentStatus | displayConditionChanges | finderFn              | endpoint
      ${STOPPING}    | ${CREATED}               | ${{}}                   | ${findStopButton}     | ${deploymentMockData.stop_url}
      ${DEPLOYING}   | ${MANUAL_DEPLOY}         | ${playDetails}          | ${findDeployButton}   | ${playDetails.playable_build.play_path}
      ${REDEPLOYING} | ${FAILED}                | ${retryDetails}         | ${findRedeployButton} | ${retryDetails.playable_build.retry_path}
    `(
      '$configConst action',
      ({ configConst, computedDeploymentStatus, displayConditionChanges, finderFn, endpoint }) => {
        describe(`${configConst} action`, () => {
          beforeEach(() => {
            factory({
              propsData: {
                computedDeploymentStatus,
                deployment: {
                  ...deploymentMockData,
                  details: displayConditionChanges,
                },
                showVisualReviewApp: false,
              },
            });
          });

          it('the button is rendered', () => {
            expect(finderFn().exists()).toBe(true);
          });

          describe('when clicked', () => {
            beforeEach(() => {
              MRWidgetService.executeInlineAction = jest.fn(() => Promise.resolve());
            });

            describe('should show a confirm dialog but not call executeInlineAction when declined', () => {
              beforeEach(() => {
                window.confirm = jest.fn(() => false);
                finderFn().trigger('click');
              });

              it('should show the confirm dialog', () => {
                expect(window.confirm).toHaveBeenCalled();
                expect(window.confirm).toHaveBeenCalledWith(
                  actionButtonMocks[configConst].confirmMessage,
                );
              });

              it('should not execute the action', () => {
                expect(MRWidgetService.executeInlineAction).not.toHaveBeenCalled();
              });
            });

            describe('should show a confirm dialog and call executeInlineAction when accepted', () => {
              beforeEach(() => {
                window.confirm = jest.fn(() => true);
                finderFn().trigger('click');
              });

              it('should show the confirm dialog', () => {
                expect(window.confirm).toHaveBeenCalled();
                expect(window.confirm).toHaveBeenCalledWith(
                  actionButtonMocks[configConst].confirmMessage,
                );
              });

              it('should execute the action with expected URL', () => {
                expect(MRWidgetService.executeInlineAction).toHaveBeenCalled();
                expect(MRWidgetService.executeInlineAction).toHaveBeenCalledWith(endpoint);
              });

              describe('response includes redirect_url', () => {
                const url = '/root/example';
                beforeEach(() => {
                  urlUtil.visitUrl = jest.fn();
                  MRWidgetService.executeInlineAction = jest.fn(() =>
                    Promise.resolve({
                      data: { redirect_url: url },
                    }),
                  );
                  window.confirm = jest.fn(() => true);
                  finderFn().trigger('click');
                });

                it('calls visit url with the redirect_url', () => {
                  expect(urlUtil.visitUrl).toHaveBeenCalled();
                  expect(urlUtil.visitUrl).toHaveBeenCalledWith(url);
                });
              });

              describe('it should call the executeAction method ', () => {
                beforeEach(() => {
                  window.confirm = jest.fn(() => true);
                  wrapper.vm.executeAction = jest.fn();
                  finderFn().trigger('click');
                });

                it('calls with the expected arguments', () => {
                  expect(wrapper.vm.executeAction).toHaveBeenCalled();
                  expect(wrapper.vm.executeAction).toHaveBeenCalledWith(
                    endpoint,
                    actionButtonMocks[configConst],
                  );
                });
              });

              describe('when executeInlineAction errors', () => {
                flash.default = jest.fn();
                MRWidgetService.executeInlineAction = jest.fn(() => Promise.reject());

                it('should call flash with error message', () => {
                  expect(flash.default).toHaveBeenCalled();
                  expect(flash.default).toHaveBeenCalledWith(
                    actionButtonMocks[configConst].errorMessage,
                  );
                });
              });
            });
          });
        });
      },
    );
  });
});
