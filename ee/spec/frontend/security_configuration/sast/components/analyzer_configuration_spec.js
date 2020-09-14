import { mount } from '@vue/test-utils';
import AnalyzerConfiguration from 'ee/security_configuration/sast/components/analyzer_configuration.vue';
import DynamicFields from 'ee/security_configuration/sast/components/dynamic_fields.vue';
import { makeAnalyzerEntities, makeEntities, makeSastCiConfiguration } from './helpers';

describe('AnalyzerConfiguration component', () => {
  let wrapper;
  let entity;

  const createComponent = ({ props = {} } = {}) => {
    wrapper = mount(AnalyzerConfiguration, {
      propsData: {
        ...props,
      },
    });
  };

  const findInputElement = () => wrapper.find('input[type="checkbox"]');
  const findDynamicFields = () => wrapper.find(DynamicFields);

  beforeEach(() => {
    [entity] = makeAnalyzerEntities(1);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('label', () => {
    beforeEach(() => {
      createComponent({
        props: { entity },
      });
    });

    it('renders the label', () => {
      expect(wrapper.text()).toContain(entity.label);
    });

    it('renders the description', () => {
      expect(wrapper.text()).toContain(entity.description);
    });
  });

  describe.each`
    initiallyChecked
    ${false}
    ${true}
  `('with checkbox initially checked $initiallyChecked ', ({ initiallyChecked }) => {
    beforeEach(() => {
      createComponent({
        props: { entity: { ...entity, enabled: initiallyChecked } },
      });
    });

    it('sets the checkbox input to the correct checked state', () => {
      expect(findInputElement().element.checked).toBe(initiallyChecked);
    });

    describe('when the user checks the checkbox', () => {
      beforeEach(() => {
        findInputElement().setChecked(!initiallyChecked);
      });

      it('emits a input event with the checked value', () => {
        expect(wrapper.emitted('input')).toEqual([[{ ...entity, enabled: !initiallyChecked }]]);
      });
    });
  });

  describe('configuration form', () => {
    describe('when there are no SastCiConfigurationEntity', () => {
      beforeEach(() => {
        createComponent({
          props: { entity },
        });
      });

      it('does not render the nested dynamic forms', () => {
        expect(findDynamicFields().exists()).toBe(false);
      });
    });

    describe('when there are one or more SastCiConfigurationEntity', () => {
      let newEntities;

      beforeEach(() => {
        [entity] = makeSastCiConfiguration().analyzers.nodes;

        createComponent({
          props: { entity },
        });
      });

      it('it renders the nested dynamic forms', () => {
        expect(findDynamicFields().exists()).toBe(true);
      });

      it('it emits an input event when dynamic form fields emits an input event', () => {
        newEntities = makeEntities(1, { field: 'new field' });
        findDynamicFields().vm.$emit('input', newEntities);

        expect(wrapper.emitted('input')).toEqual([
          [{ ...entity, variables: { nodes: newEntities } }],
        ]);
      });

      it('passes the disabled prop to dynamic fields component', () => {
        expect(findDynamicFields().props('disabled')).toBe(!entity.enabled);
      });

      it('passes the entities prop to the dynamic fields component', () => {
        expect(findDynamicFields().props('entities')).toBe(newEntities);
      });
    });
  });
});
