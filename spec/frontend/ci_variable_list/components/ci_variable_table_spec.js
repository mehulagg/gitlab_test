import Vuex from 'vuex';
import { createLocalVue, mount } from '@vue/test-utils';
import CiVariableTable from '~/ci_variable_list/components/ci_variable_table.vue';
import createStore from '~/ci_variable_list/store';
import mockData from '../services/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Ci variable table', () => {
  let wrapper;
  let store;

  const actionMocks = {
    fetchVariables: jest.fn(),
    deleteVariable: jest.fn(),
    editVariable: jest.fn(),
    toggleValues: jest.fn(),
  };

  const addEnvironmentScopeField = jest.fn();

  const createComponent = () => {
    store = createStore();
    wrapper = mount(CiVariableTable, {
      localVue,
      store,
      methods: {
        ...actionMocks,
        addEnvironmentScopeField,
      },
    });
  };

  const findDeleteButton = () => wrapper.find('.js-delete-ci-variable');
  const findRevealButton = () => wrapper.find('.js-secret-value-reveal-button');
  const findEditButton = () => wrapper.find('.js-edit-ci-variable');

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('dispatches fetchVariables when mounted', () => {
    expect(actionMocks.fetchVariables).toHaveBeenCalled();
  });

  it('adds environment scope field if not a group', () => {
    wrapper.vm.$store.state.isGroup = false;
    expect(addEnvironmentScopeField).toHaveBeenCalled();
  });

  describe('Renders correct data', () => {
    it('displays empty message when variables are not present', () => {
      expect(wrapper.find('.empty-variables').exists()).toBe(true);
    });

    it('displays correct amount of variables present and no empty message', () => {
      wrapper.vm.$store.state.variables = mockData.mockVariables;

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.findAll('.js-ci-variable-row').length).toBe(3);
        expect(wrapper.find('.empty-variables').exists()).toBe(false);
      });
    });
  });

  describe('Table click actions', () => {
    it('dispatches deleteVariable with correct variable to delete', () => {
      wrapper.vm.$store.state.variables = mockData.mockVariables;

      return wrapper.vm.$nextTick(() => {
        const variableToDelete = mockData.mockVariables[0];
        findDeleteButton().trigger('click');
        expect(actionMocks.deleteVariable).toHaveBeenCalledWith(variableToDelete);
        expect(mockData.mockVariables.length).toBe(2);
      });
    });

    it('reveals secret values when button is clicked', () => {
      findRevealButton().trigger('click');
      expect(actionMocks.toggleValues).toHaveBeenCalledWith(false);
    });

    it('dispatches editVariable with correct variable to edit', () => {
      wrapper.vm.$store.state.variables = mockData.mockVariables;

      return wrapper.vm.$nextTick(() => {
        const variableToEdit = mockData.mockVariables[0];
        findEditButton().trigger('click');
        expect(actionMocks.editVariable).toHaveBeenCalledWith(variableToEdit);
      });
    });
  });
});
