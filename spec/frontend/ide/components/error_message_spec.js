import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import ErrorMessage from '~/ide/components/error_message.vue';
import { GlLoadingIcon, GlAlert } from '@gitlab/ui';

const mockMessage = {
  text: 'some <strong>text</strong>',
  actionText: 'test action',
  actionPayload: 'testActionPayload',
};

const createComponent = function(messageOptions = {}) {
  return mount(ErrorMessage, {
    propsData: {
      message: Object.assign({}, mockMessage, messageOptions),
    },
    stubs: {
      GlLoadingIcon: true,
    },
  });
};

describe('IDE error message component', () => {
  it('renders error message', () => {
    const wrapper = createComponent();
    expect(wrapper.text()).toContain('some text');
    expect(wrapper.html()).toMatchSnapshot();
  });

  describe('dismissal', () => {
    it('is not visible if there is an action available', () => {
      const actionMock = jest.fn();
      const wrapper = createComponent({ action: actionMock });
      expect(wrapper.find('button.gl-alert-dismiss').exists()).toBe(false);
    });

    it('will trigger the custom dismiss event', () => {
      const wrapper = createComponent();
      const setErrorMessageStub = jest.fn();
      wrapper.setMethods({ setErrorMessage: setErrorMessageStub });

      const alertComponent = wrapper.find(GlAlert);
      alertComponent.vm.$emit('dismiss');

      expect(setErrorMessageStub).toHaveBeenCalledWith(null);
    });
  });

  describe('message actions', () => {
    it('will fire local action logic accordingly', () => {
      const actionMock = jest.fn().mockResolvedValue(true);
      const wrapper = createComponent({ action: actionMock });
      const actionButton = wrapper.find('button.gl-alert-action');

      actionButton.trigger('click');
      expect(actionMock).toHaveBeenCalledWith(mockMessage.actionPayload);
    });

    it('will correctly set loading state amd prevent further invocation', () => {
      let resolveAction;
      const actionMock = jest.fn().mockImplementation(
        () =>
          new Promise(resolve => {
            resolveAction = resolve;
          }),
      );
      const wrapper = createComponent({ action: actionMock });
      const actionButton = wrapper.find('button.gl-alert-action');
      const spinner = wrapper.find(GlLoadingIcon);

      expect(spinner.isVisible()).toBe(false);
      actionButton.trigger('click');
      expect(actionMock.mock.calls.length).toBe(1);

      return nextTick()
        .then(() => {
          expect(spinner.isVisible()).toBe(true);
          actionButton.trigger('click');
          // This click should not add another call to the message action
          expect(actionMock.mock.calls.length).toBe(1);
          resolveAction();
        })
        .then(nextTick())
        .then(() => {
          expect(spinner.isVisible()).toBe(false);
        });
    });
  });
});
