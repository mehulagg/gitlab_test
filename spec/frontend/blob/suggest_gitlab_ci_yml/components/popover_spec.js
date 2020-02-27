import { shallowMount } from '@vue/test-utils';
import Popover from '~/blob/suggest_gitlab_ci_yml/components/popover.vue';
import Cookies from 'js-cookie';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';
import * as utils from '~/lib/utils/common_utils';

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  scrollToElement: jest.fn(),
}));

const target = 'gitlab-ci-yml-selector';
const dismissKey = 'suggest_gitlab_ci_yml_99';
const cssClass = 'css-class';
const defaultTrackLabel = 'any-name';
const commitTrackLabel = 'suggest_gitlab_ci_yml_commit_changes';
const humanAccess = 'owner';

describe('Suggest gitlab-ci.yml Popover', () => {
  let wrapper;

  function createWrapper(trackLabel) {
    wrapper = shallowMount(Popover, {
      propsData: {
        target,
        cssClass,
        trackLabel,
        dismissKey,
        humanAccess,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when no dismiss cookie is set', () => {
    beforeEach(() => {
      createWrapper(defaultTrackLabel);
    });

    it('sets popoverDismissed to false', () => {
      expect(wrapper.vm.popoverDismissed).toEqual(false);
    });
  });

  describe('when the dismiss cookie is set', () => {
    beforeEach(() => {
      Cookies.set(dismissKey, true);
      createWrapper(defaultTrackLabel);
    });

    it('sets popoverDismissed to true', () => {
      expect(wrapper.vm.popoverDismissed).toEqual(true);
    });

    afterEach(() => {
      Cookies.remove(dismissKey);
    });
  });

  describe('tracking', () => {
    let trackingSpy;

    beforeEach(() => {
      createWrapper(commitTrackLabel);
      trackingSpy = mockTracking('_category_', wrapper.element, jest.spyOn);
    });

    afterEach(() => {
      unmockTracking();
    });

    it('sends a tracking event with the expected properies for the popover being viewed', () => {
      // const expectedCategory = 'projects:blob:new';
      // const expectedAction = 'generic';
      const expectedLabel = 'suggest_gitlab_ci_yml_commit_changes';
      const expectedProperty = 'owner';

      document.body.dataset.page = 'projects:blob:new';

      wrapper.vm.trackOnShow();

      expect(trackingSpy).toHaveBeenCalledWith(undefined, undefined, {
      // expect(trackingSpy).toHaveBeenCalledWith(expectedCategory, expectedAction,{
        label: expectedLabel,
        property: expectedProperty,
      });
    });
  });

  describe('when the popover is mounted with the trackLabel of the Confirm button popover at the bottom of the page', () => {
    it('calls scrollToElement so that the Confirm button and popover will be in sight', () => {
      const scrollToElementSpy = jest.spyOn(utils, 'scrollToElement');
      const commitTrackLabel = 'suggest_commit_first_project_gitlab_ci_yml';

      createWrapper(commitTrackLabel);

      expect(scrollToElementSpy).toHaveBeenCalled();
    });
  });
});
