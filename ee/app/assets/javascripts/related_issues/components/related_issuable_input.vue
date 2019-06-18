<script>
import $ from 'jquery';
import issueToken from './issue_token.vue';

const SPACE_FACTOR = 1;

export default {
  name: 'RelatedIssuableInput',
  components: {
    issueToken,
  },
  props: {
    references: {
      type: Array,
      required: false,
      default: () => [],
    },
    pathIdSeparator: {
      type: String,
      required: true,
    },
    inputValue: {
      type: String,
      required: false,
      default: '',
    },
    inputPlaceholder: {
      type: String,
      required: true,
    },
    focusOnMount: {
      type: Boolean,
      required: false,
      default: false,
    },
    useInput: {
      type: Function,
      required: false,
      default: () => {},
    },
    isAutoCompleteOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      isInputFocused: false,
    };
  },
  mounted() {
    const $input = $(this.$refs.input);
    this.useInput($input);
    if (this.focusOnMount) {
      this.$refs.input.focus();
    }
  },
  beforeDestroy() {
    const $input = $(this.$refs.input);
    $input.off('shown-issues.atwho');
    $input.off('hidden-issues.atwho');
    $input.off('inserted-issues.atwho', this.onInput);
  },
  methods: {
    onInputWrapperClick() {
      this.$refs.input.focus();
    },
    onInput() {
      const { value } = this.$refs.input;
      const caretPos = $(this.$refs.input).caret('pos');
      const rawRefs = value.split(/\s/);
      let touchedReference;
      let position = 0;

      const untouchedRawRefs = rawRefs
        .filter(ref => {
          let isTouched = false;

          if (caretPos >= position && caretPos <= position + ref.length) {
            touchedReference = ref;
            isTouched = true;
          }

          position = position + ref.length + SPACE_FACTOR;

          return !isTouched;
        })
        .filter(ref => ref.trim().length > 0);

      this.$emit('addIssuableFormInput', {
        newValue: value,
        untouchedRawReferences: untouchedRawRefs,
        touchedReference,
        caretPos,
      });
    },
    onBlur() {
      this.isInputFocused = false;

      // Avoid tokenizing partial input when clicking an autocomplete item
      if (!this.isAutoCompleteOpen) {
        const { value } = this.$refs.input;
        this.$emit('addIssuableFormBlur', value);
      }
    },
    onFocus() {
      this.isInputFocused = true;
    },
  },
};
</script>

<template>
  <div
    ref="issuableFormWrapper"
    :class="{ focus: isInputFocused }"
    class="add-issuable-form-input-wrapper form-control"
    role="button"
    @click="onInputWrapperClick"
  >
    <ul class="add-issuable-form-input-token-list">
      <!--
          We need to ensure this key changes any time the pendingReferences array is updated
          else two consecutive pending ref strings in an array with the same name will collide
          and cause odd behavior when one is removed.
        -->
      <li
        v-for="(reference, index) in references"
        :key="`related-issues-token-${reference}`"
        class="js-add-issuable-form-token-list-item add-issuable-form-token-list-item"
      >
        <issue-token
          :id-key="index"
          :display-reference="reference"
          :can-remove="true"
          :is-condensed="true"
          :path-id-separator="pathIdSeparator"
          event-namespace="pendingIssuable"
          @pendingIssuableRemoveRequest="
            params => {
              $emit('pendingIssuableRemoveRequest', params);
            }
          "
        />
      </li>
      <li class="add-issuable-form-input-list-item">
        <input
          ref="input"
          :value="inputValue"
          :placeholder="inputPlaceholder"
          type="text"
          class="js-add-issuable-form-input add-issuable-form-input qa-add-issue-input"
          @input="onInput"
          @focus="onFocus"
          @blur="onBlur"
          @keyup.escape.exact="$emit('addIssuableFormCancel')"
        />
      </li>
    </ul>
  </div>
</template>