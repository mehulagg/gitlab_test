<script>
import GlFormInput from '../form/form_input/form_input.vue';
import GlButton from '../button/button.vue';
import GlTooltip from '../../../directives/tooltip';

export default {
  components: {
    GlFormInput,
    GlButton,
  },
  directives: {
    GlTooltip,
  },
  inheritAttrs: false,
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      content: this.value,
    };
  },
  computed: {
    isDisabled() {
      return this.$attrs.disabled;
    },
    hasValue() {
      return this.content !== '';
    },
    isResetButtonVisible() {
      return !this.isDisabled && this.hasValue;
    },
  },
  methods: {
    clearInput() {
      this.content = '';
      this.focusInput();
    },
    focusInput() {
      this.$refs.input.$el.focus();
    },
    onInput() {
      this.$emit('input', this.content);
    },
    onSearch() {
      this.$emit('submit', this.content);
    },
  },
};
</script>

<template>
  <div>
    <div class="position-relative ms-no-clear d-flex flex-fill">
      
      <gl-form-input
        ref="input"
        v-model="content"
        v-bind="$attrs"
        :value="content"
        :class="{ 'pr-5': !isResetButtonVisible, 'pr-6': isResetButtonVisible }"
        v-on="$listeners"
        @input="onInput"
        @keyup.enter.native="onSearch"
      />
      <div
        class="position-absolute position-top-0 h-100 d-flex align-items-center text-muted position-right-0"
      >
        <i
          v-show="isResetButtonVisible"
          v-gl-tooltip.hover
          class="fa fa-times fa-lg pl-2 pr-2 cursor-pointer"
          aria-hidden="true"
          title="Clear"
          @click="clearInput"
        ></i>
        <div class="border-left">
          <gl-button
            class="btn-transparent"
            aria-label="Search Button"
            :disabled="isDisabled"
          >
            <i
              class="fa fa-search"
              aria-hidden="true"
              @click="onSearch"
            ></i>
          </gl-button>
        </div>
      </div>
    </div>
  </div>
</template>
