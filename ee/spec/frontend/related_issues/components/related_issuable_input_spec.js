import { shallowMount, mount } from '@vue/test-utils';
import RelatedIssuableInput from 'ee/related_issues/components/related_issuable_input.vue';

describe('RelatedIssuableInput', () => {
  describe('autocomplete', () => {
    describe('with autoCompleteSources', () => {
      const inputPlaceholder = 'placeholder text';
      const propsData = {
        inputValue: '',
        references: [],
        pathIdSeparator: '#',
        autoCompleteSources: {
          issues: '/h5bp/html5-boilerplate/-/autocomplete_sources/issues',
        },
        inputPlaceholder,
      };

      it('shows placeholder text', () => {
        const wrapper = shallowMount(RelatedIssuableInput, { propsData });

        expect(wrapper.find({ ref: 'input' }).attributes().placeholder).toBe(inputPlaceholder);
      });

      it('has GfmAutoComplete', () => {
        const wrapper = shallowMount(RelatedIssuableInput, { propsData });

        console.log(Object.keys(wrapper.vm).filter(key => key.includes('gfm')));
        expect(wrapper.vm.gfmAutoComplete).toBeDefined();
      });
    });

    describe('with no autoCompleteSources', () => {
      it('shows placeholder text', () => {
        throw new Error('TODO');
      });

      it('does not have GfmAutoComplete', () => {
        throw new Error('TODO');
      });
    });
  });

  describe('focus', () => {
    it('when clicking anywhere on the input wrapper it should focus the input', () => {
      throw new Error('TODO');
    });
  });

  describe('when filling in the input', () => {
    it('emits addIssuableFormInput with data', () => {
      // KARMA VERSION
      // spyOn(vm, '$emit');
      // const newInputValue = 'filling in things';
      // const untouchedRawReferences = newInputValue.trim().split(/\s/);
      // const touchedReference = untouchedRawReferences.pop();

      // vm.$refs.input.value = newInputValue;
      // vm.onInput();

      // expect(vm.$emit).toHaveBeenCalledWith('addIssuableFormInput', {
      //   newValue: newInputValue,
      //   caretPos: newInputValue.length,
      //   untouchedRawReferences,
      //   touchedReference,
      // });
      throw new Error('TODO');
    });
  });

  describe('when using autocomplete', () => {
    it('clicks on autocomplete option and fills in the input value', () => {
      throw new Error('TODO');
    });
  });
});
