<script>
import GlFormInput from '../form/form_input/form_input.vue';
import GlLoadingIcon from '../loading_icon/loading_icon.vue';

export default {
  iconWrapperClasses: 'position-absolute position-top-0 h-100 d-flex align-items-center text-muted',
  components: {
    GlFormInput,
    GlLoadingIcon,
  },
  inheritAttrs: false,
  props: {
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      hasValue: false,
    };
  },
  computed: {
    hasRightIcon() {
      return this.isResetButtonVisible || this.isLoading;
    },
    isResetButtonVisible() {
      return !this.$attrs.disabled && this.hasValue;
    },
    inputAttributes() {
      const attributes = Object.assign(
        {
          type: 'text',
          placeholder: 'Search',
        },
        this.$attrs
      );

      if (!attributes['aria-label']) {
        attributes['aria-label'] = attributes.placeholder;
      }

      return attributes;
    },
  },
  methods: {
    clearInput() {
      this.$refs.input.$el.value = '';
      this.$refs.input.$emit('input', '');
      this.focusInput();
    },
    focusInput() {
      this.$refs.input.$el.focus();
    },
    onChange(value) {
      this.hasValue = value !== '';
      this.$emit('change', value);
    },
    onInput(value) {
      this.hasValue = value !== '';
      this.$emit('input', value);
    },
  },
};
</script>

<template>
  <div class="position-relative ms-no-clear">
    <gl-form-input
      ref="input"
      v-bind="inputAttributes"
      class="pl-5"
      :class="{ 'pr-5': isResetButtonVisible }"
      v-on="$listeners"
      @change="onChange"
      @input="onInput"
    />
    <div
      :class="$options.iconWrapperClasses"
      class="pl-2 pr-2 position-left-0"
      @click="focusInput"
    >
      <!--
        To match the design spec, added 3px margin so the icon is even 16px wide now.
        This can be removed once SVG based icons kick in.

        Discussion: https://gitlab.com/gitlab-org/gitlab-ui/merge_requests/153#note_133591712
      -->
      <i
        style="margin: 0 1.5px"
        class="fa fa-search"
        aria-hidden="true"
      ></i>
    </div>
    <div
      v-show="hasRightIcon"
      :class="$options.iconWrapperClasses"
      class="pr-2 position-right-0"
    >
      <gl-loading-icon
        v-show="isLoading"
        :inline="true"
      />
      <i
        v-show="isResetButtonVisible"
        class="fa fa-times-circle fa-lg pl-2"
        aria-hidden="true"
        style="cursor: pointer;"
        @click="clearInput"
      ></i>
    </div>
  </div>
</template>
