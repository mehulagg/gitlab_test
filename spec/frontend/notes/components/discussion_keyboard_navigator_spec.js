/* global Mousetrap */
import 'mousetrap';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import DiscussionKeyboardNavigator from '~/notes/components/discussion_keyboard_navigator.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('notes/components/discussion_keyboard_navigator', () => {
  let wrapper;
  let store;

  const createComponent = (options = {}) => {
    store = new Vuex.Store();

    wrapper = shallowMount(DiscussionKeyboardNavigator, {
      localVue,
      store,
      ...options,
    });

    wrapper.vm.jumpToNextUnresolvedDiscussion = jest.fn();
    wrapper.vm.jumpToPreviousUnresolvedDiscussion = jest.fn();
  };

  afterEach(() => {
    wrapper.destroy();
    store = null;
  });

  describe.each`
    isDiffView
    ${true}
    ${false}
  `('when isDiffView is $isDiffView', ({ isDiffView }) => {
    beforeEach(() => {
      createComponent({ propsData: { isDiffView } });
    });

    it('calls jumpToNextUnresolvedDiscussion when pressing `n`', () => {
      Mousetrap.trigger('n');

      expect(wrapper.vm.jumpToNextUnresolvedDiscussion).toHaveBeenCalled();
    });

    it('calls jumpToPreviousUnresolvedDiscussion when pressing `p`', () => {
      Mousetrap.trigger('p');

      expect(wrapper.vm.jumpToPreviousUnresolvedDiscussion).toHaveBeenCalled();
    });
  });

  describe('on destroy', () => {
    beforeEach(() => {
      jest.spyOn(Mousetrap, 'unbind');

      createComponent();

      wrapper.destroy();
    });

    it('unbinds keys', () => {
      expect(Mousetrap.unbind).toHaveBeenCalledWith('n');
      expect(Mousetrap.unbind).toHaveBeenCalledWith('p');
    });

    it('does not call jumpToNextUnresolvedDiscussion when pressing `n`', () => {
      Mousetrap.trigger('n');

      expect(wrapper.vm.jumpToNextUnresolvedDiscussion).not.toHaveBeenCalled();
    });

    it('does not call jumpToPreviousUnresolvedDiscussion when pressing `p`', () => {
      Mousetrap.trigger('p');

      expect(wrapper.vm.jumpToPreviousUnresolvedDiscussion).not.toHaveBeenCalled();
    });
  });
});
