<script>
import { GlButton } from '@gitlab/ui';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import { s__ } from '~/locale';

export default {
  name: 'DismissalCommentModalFooter',
  components: {
    GlButton,
    LoadingButton,
  },
  props: {
    isDismissingVulnerability: {
      type: Boolean,
      required: false,
      default: false,
    },
    isEditingDismissal: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed:{
    buttonLabel() {
      debugger;
      return this.isEditingDismissal ? s__('vulnerability|Save Comment') : 
      s__('vulnerability|Add comment & dismiss')
    }
  }
};
</script>

<template>
  <div>
    <gl-button @click="$emit('cancel')">
      {{ __('Cancel') }}
    </gl-button>

    <loading-button
      :loading="isDismissingVulnerability"
      :disabled="isDismissingVulnerability"
      :label="buttonLabel"
      container-class="btn btn-close"
      @click="$emit('dismissVulnerability')"
    />
  </div>
</template>
