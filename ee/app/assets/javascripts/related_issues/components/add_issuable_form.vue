<script>
import GfmAutoComplete from 'ee_else_ce/gfm_auto_complete';
import { GlLoadingIcon } from '@gitlab/ui';
import RelatedIssuableInput from './related_issuable_input.vue';
import { autoCompleteTextMap, inputPlaceholderTextMap } from '../constants';

export default {
  name: 'AddIssuableForm',
  components: {
    GlLoadingIcon,
    RelatedIssuableInput,
  },
  props: {
    inputValue: {
      type: String,
      required: true,
    },
    pendingReferences: {
      type: Array,
      required: false,
      default: () => [],
    },
    autoCompleteSources: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    isSubmitting: {
      type: Boolean,
      required: false,
      default: false,
    },
    pathIdSeparator: {
      type: String,
      required: true,
    },
    issuableType: {
      type: String,
      required: false,
      default: 'issue',
    },
  },

  data() {
    return {
      isAutoCompleteOpen: false,
      domInputValue: this.inputValue,
    };
  },

  computed: {
    inputPlaceholder() {
      const { issuableType, allowAutoComplete } = this;
      const allowAutoCompleteText = autoCompleteTextMap[allowAutoComplete][issuableType];
      return `${inputPlaceholderTextMap[issuableType]}${allowAutoCompleteText}`;
    },
    isSubmitButtonDisabled() {
      return (
        (this.inputValue.length === 0 && this.pendingReferences.length === 0) || this.isSubmitting
      );
    },
    allowAutoComplete() {
      return Object.keys(this.autoCompleteSources).length > 0;
    },
  },
  methods: {
    onAutoCompleteToggled(isOpen) {
      this.isAutoCompleteOpen = isOpen;
    },
    onPendingIssuableRemoveRequest(params) {
      this.$emit('pendingIssuableRemoveRequest', params);
    },
    onFormSubmit() {
      this.$emit('addIssuableFormSubmit', this.domInputValue);
    },
    onFormCancel() {
      this.$emit('addIssuableFormCancel');
    },
    useInput($input) {
      $input.on('input', this.updateDomInputValue);
      if (this.allowAutoComplete) {
        this.gfmAutoComplete = new GfmAutoComplete(this.autoCompleteSources);
        this.gfmAutoComplete.setup($input, {
          issues: true,
          epics: true,
        });
      }
      $input.on('shown-issues.atwho', this.onAutoCompleteToggled.bind(this, true));
      $input.on('hidden-issues.atwho', this.onAutoCompleteToggled.bind(this, false));
    },
    updateDomInputValue(e) {
      this.domInputValue = e.target.value;
    },
  },
};
</script>

<template>
  <form @submit.prevent="onFormSubmit">
    <!-- TODO:
      Mayber onInput, onBlur and onFocus should be moved to listeners??
    -->
    <related-issuable-input
      ref="relatedIssuableInput"
      :focus-on-mount="true"
      :references="pendingReferences"
      :path-id-separator="pathIdSeparator"
      :input-value="inputValue"
      :input-placeholder="inputPlaceholder"
      :use-input="useInput"
      :is-autocomplete-open="isAutoCompleteOpen"
      @formCancel="onFormCancel"
      @pendingIssuableRemoveRequest="onPendingIssuableRemoveRequest"
      @addIssuableFormBlur="
        params => {
          $emit('addIssuableFormBlur', params);
        }
      "
      @addIssuableFormInput="
        params => {
          $emit('addIssuableFormInput', params);
        }
      "
    />
    <div class="add-issuable-form-actions clearfix">
      <button
        ref="addButton"
        :disabled="isSubmitButtonDisabled"
        type="submit"
        class="js-add-issuable-form-add-button btn btn-success float-left qa-add-issue-button"
      >
        Add
        <gl-loading-icon v-if="isSubmitting" ref="loadingIcon" :inline="true" />
      </button>
      <button type="button" class="btn btn-default float-right" @click="onFormCancel">
        Cancel
      </button>
    </div>
  </form>
</template>
