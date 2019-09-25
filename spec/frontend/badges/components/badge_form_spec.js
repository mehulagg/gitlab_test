import Vue from 'vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import store from '~/badges/store';
import createEmptyBadge from '~/badges/empty_badge';
import BadgeForm from '~/badges/components/badge_form.vue';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { DUMMY_IMAGE_URL, TEST_HOST } from 'helpers/test_constants'; // avoid preview background process

BadgeForm.methods.debouncedPreview = () => {};

describe('BadgeForm component', () => {
  const Component = Vue.extend(BadgeForm);
  let axiosMock;
  let vm;
  beforeEach(() => {
    setFixtures(`
      <div id="dummy-element"></div>
    `);
    axiosMock = new MockAdapter(axios);
  });
  afterEach(() => {
    vm.$destroy();
    axiosMock.restore();
  });
  describe('methods', () => {
    beforeEach(() => {
      store.replaceState({ isEditing: false });
      vm = mountComponentWithStore(Component, {
        el: '#dummy-element',
        store,
      });
    });
    describe('onCancel', () => {
      it('calls stopEditing', () => {
        jest.spyOn(vm, 'stopEditing').mockReturnValue();
        vm.onCancel();
        expect(vm.stopEditing).toHaveBeenCalled();
      });
    });
  });

  const sharedSubmitTests = submitAction => {
    const imageUrlSelector = '#badge-image-url';

    const findImageUrlElement = () => vm.$el.querySelector(imageUrlSelector);

    const linkUrlSelector = '#badge-link-url';

    const findLinkUrlElement = () => vm.$el.querySelector(linkUrlSelector);

    const setValue = (inputElementSelector, url) => {
      const inputElement = vm.$el.querySelector(inputElementSelector);
      inputElement.value = url;
      inputElement.dispatchEvent(new Event('input'));
    };

    const submitForm = () => {
      const submitButton = vm.$el.querySelector('button[type="submit"]');
      submitButton.click();
    };

    const expectInvalidInput = inputElementSelector => {
      const inputElement = vm.$el.querySelector(inputElementSelector);
      expect(inputElement.checkValidity()).toBe(false);
      const feedbackElement = vm.$el.querySelector(`${inputElementSelector} + .invalid-feedback`);
      expect(feedbackElement).toBeVisible();
    };

    beforeEach(() => {
      jest.spyOn(vm, submitAction).mockReturnValue(Promise.resolve());
      store.replaceState({
        ...store.state,
        badgeInAddForm: createEmptyBadge(),
        badgeInEditForm: createEmptyBadge(),
        isSaving: false,
      });
      setValue(linkUrlSelector, `${TEST_HOST}/link/url`);
      setValue(imageUrlSelector, `${window.location.origin}${DUMMY_IMAGE_URL}`);
    });

    it('returns immediately if imageUrl is empty', () => {
      setValue(imageUrlSelector, '');
      submitForm();
      expectInvalidInput(imageUrlSelector);
      expect(vm[submitAction]).not.toHaveBeenCalled();
    });
    it('returns immediately if imageUrl is malformed', () => {
      setValue(imageUrlSelector, 'not-a-url');
      submitForm();
      expectInvalidInput(imageUrlSelector);
      expect(vm[submitAction]).not.toHaveBeenCalled();
    });
    it('returns immediately if linkUrl is empty', () => {
      setValue(linkUrlSelector, '');
      submitForm();
      expectInvalidInput(linkUrlSelector);
      expect(vm[submitAction]).not.toHaveBeenCalled();
    });
    it('returns immediately if linkUrl is malformed', () => {
      setValue(linkUrlSelector, 'not-a-url');
      submitForm();
      expectInvalidInput(linkUrlSelector);
      expect(vm[submitAction]).not.toHaveBeenCalled();
    });
    it(`calls ${submitAction}`, () => {
      submitForm();
      expect(findImageUrlElement().checkValidity()).toBe(true);
      expect(findLinkUrlElement().checkValidity()).toBe(true);
      expect(vm[submitAction]).toHaveBeenCalled();
    });
  };

  describe('if isEditing is false', () => {
    beforeEach(() => {
      store.replaceState({ isEditing: false });
      vm = mountComponentWithStore(Component, {
        el: '#dummy-element',
        store,
      });
    });
    it('renders one button', () => {
      expect(vm.$el.querySelector('.row-content-block')).toBeNull();
      const buttons = vm.$el.querySelectorAll('.form-group:last-of-type button');
      expect(buttons.length).toBe(1);
      const buttonAddElement = buttons[0];
      expect(buttonAddElement).toBeVisible();
      expect(buttonAddElement).toHaveText('Add badge');
    });
    sharedSubmitTests('addBadge');
  });
  describe('if isEditing is true', () => {
    beforeEach(() => {
      store.replaceState({ isEditing: true });
      vm = mountComponentWithStore(Component, {
        el: '#dummy-element',
        store,
      });
    });
    it('renders two buttons', () => {
      const buttons = vm.$el.querySelectorAll('.row-content-block button');
      expect(buttons.length).toBe(2);
      const buttonSaveElement = buttons[0];
      expect(buttonSaveElement).toBeVisible();
      expect(buttonSaveElement).toHaveText('Save changes');
      const buttonCancelElement = buttons[1];
      expect(buttonCancelElement).toBeVisible();
      expect(buttonCancelElement).toHaveText('Cancel');
    });
    sharedSubmitTests('saveBadge');
  });
});
