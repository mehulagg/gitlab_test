import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlModal } from '@gitlab/ui';
import CiVariableModal from '~/ci_variable_list/components/ci_variable_modal.vue';
import createStore from '~/ci_variable_list/store';
import mockData from '../services/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Ci variable modal', () => {
  let wrapper;
  let store;

  const actionMocks = {
    addVariable: jest.fn(),
    updateVariable: jest.fn(),
    resetEditing: jest.fn(),
    clearModal: jest.fn(),
  };

  const createComponent = () => {
    store = createStore();
    wrapper = shallowMount(CiVariableModal, {
      localVue,
      store,
      methods: {
        ...actionMocks,
      },
    });
  };

  const modal = () => wrapper.find(GlModal);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('button is disabled when no key/value pair are present', () => {
    expect(wrapper.vm.canSubmit).toBeFalsy();
  });

  describe('Adding a new variable', () => {
    beforeEach(() => {
      const [variable] = mockData.mockVariables;
      wrapper.vm.$store.state.variable = variable;
    });

    it('button is enabled when key/value pair are present', () => {
      expect(wrapper.vm.canSubmit).toBeTruthy();
    });

    it('masked checkbox is enabled when value meets regex requirements', () => {
      expect(wrapper.vm.canMask).toBeTruthy();
      return wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.js-masked-ci-variable').attributes('disabled')).toBeFalsy();
      });
    });

    it('Add variable button dispatches addVariable action', () => {
      modal().vm.$emit('ok');
      expect(actionMocks.addVariable).toHaveBeenCalled();
    });

    it('Clears the modal state once modal is hidden', () => {
      modal().vm.$emit('hidden');
      expect(actionMocks.clearModal).toHaveBeenCalled();
    });
  });

  describe('Editing a variable', () => {
    beforeEach(() => {
      const [variable] = mockData.mockVariables;
      wrapper.vm.$store.state.variableBeingEdited = variable;
    });
    it('button text is Update variable when updating', () => {
      expect(wrapper.vm.modalActionText).toBe('Update Variable');
    });

    it('Update variable button dispatches updateVariable with correct variable', () => {
      modal().vm.$emit('ok');
      expect(actionMocks.updateVariable).toHaveBeenCalledWith(
        wrapper.vm.$store.state.variableBeingEdited,
      );
    });

    it('Resets the editing state once modal is hidden', () => {
      modal().vm.$emit('hidden');
      expect(actionMocks.resetEditing).toHaveBeenCalled();
    });
  });
});
