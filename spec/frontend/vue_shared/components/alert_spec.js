import { mount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';
import VueAlert from '~/vue_shared/components/alert.vue';

describe('VueAlert', () => {
  let wrapper;

  const propsData = {
    message: 'This is an alert',
    variant: undefined,
    title: undefined,
    dismissible: undefined,
    primaryButtonLink: undefined,
    primaryButtonText: undefined,
    secondaryButtonLink: undefined,
    secondaryButtonText: undefined,
  };

  const createComponent = () => {
    wrapper = mount(VueAlert, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findAlert = () => wrapper.find(GlAlert);
  const findAlertTitle = () => findAlert().find('.gl-alert-title');
  const findAlertDismiss = () => findAlert().find('.gl-alert-action');
  const findAlertPrimaryButton = () => findAlert().find('.gl-alert-action');
  const findAlertSecondaryButton = () => findAlert().find('.btn-secondary');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('showAlert is true (default)', () => {
      it('renders GlAlert', () => {
        expect(findAlert().exists()).toBe(true);
      });
    });

    describe('showAlert is false', () => {
      beforeEach(() => {
        wrapper.vm.showAlert = false;
      });

      it('hides GlAlert', () => {
        expect(findAlert().exists()).toBe(false);
      });
    });
  });

  describe('props', () => {
    describe('message', () => {
      let messageValue;

      beforeEach(() => {
        messageValue = 'Alert Message';
        propsData.message = messageValue;
        createComponent();
      });

      it('sets alert message correctly', () => {
        expect(findAlert().text()).toBe(messageValue);
      });
    });

    describe('variant', () => {
      let variantValue;

      beforeEach(() => {
        variantValue = 'tip';
        propsData.variant = variantValue;
        createComponent();
      });

      it('sets alert class correctly', () => {
        expect(findAlert().classes()).toContain(`gl-alert-${variantValue}`);
      });
    });

    describe('title', () => {
      let titleValue;

      beforeEach(() => {
        titleValue = 'Alert Title';
        propsData.title = titleValue;
        createComponent();
      });

      it('sets alert title correctly', () => {
        expect(findAlertTitle().text()).toBe(titleValue);
      });
    });

    describe('dismissible', () => {
      beforeEach(() => {
        propsData.dismissible = false;
        createComponent();
      });

      it('Hides dismiss button', () => {
        expect(findAlertDismiss().exists()).toBe(false);
      });
    });

    describe('primaryButton', () => {
      let buttonLink;
      let buttonText;

      beforeEach(() => {
        buttonLink = 'https://gitlab.com';
        buttonText = 'Primary Button';
        propsData.primaryButtonLink = buttonLink;
        propsData.primaryButtonText = buttonText;
        createComponent();
      });

      it('sets alert primary button correctly', () => {
        expect(findAlertPrimaryButton().text()).toBe(buttonText);
        expect(findAlertPrimaryButton().attributes('href')).toBe(buttonLink);
      });
    });

    describe('secondaryButton', () => {
      let buttonLink;
      let buttonText;

      beforeEach(() => {
        buttonLink = 'https://about.gitlab.com';
        buttonText = 'Secondary Button';
        propsData.secondaryButtonLink = buttonLink;
        propsData.secondaryButtonText = buttonText;
        createComponent();
      });

      it('sets alert secondary button correctly', () => {
        expect(findAlertSecondaryButton().text()).toBe(buttonText);
        expect(findAlertSecondaryButton().attributes('href')).toBe(buttonLink);
      });
    });
  });

  describe('events', () => {
    describe('@dismiss', () => {
      beforeEach(() => {
        createComponent();
      });

      it('sets showAlert to false', () => {
        expect(wrapper.vm.showAlert).toBe(true);
        findAlert().vm.$emit('dismiss');
        expect(wrapper.vm.showAlert).toBe(false);
      });
    });
  });
});
