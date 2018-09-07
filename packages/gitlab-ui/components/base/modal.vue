<script>
import BModal from 'bootstrap-vue/es/components/modal/modal';

export default {
  components: {
    BModal,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
    titleTag: {
      type: String,
      required: false,
      default: 'h4',
    },
  },
};
</script>

<template>
  <b-modal
    :id="modalId"
    :title-tag="titleTag"
    v-bind="$attrs"
    v-on="$listeners"
    lazy
  >
    <slot></slot>
    <slot
      slot="modal-header"
      name="modal-header"
    >
    </slot>
    <slot
      slot="modal-title"
      name="modal-title"
    >
    </slot>
    <slot
      slot="modal-header-close"
      name="modal-header-close"
    >
    </slot>
    <slot
      slot="modal-footer"
      name="modal-footer"
    >
    </slot>
    <slot
      slot="modal-ok"
      name="modal-ok"
    >
    </slot>
    <slot
      slot="modal-cancel"
      name="modal-cancel"
    >
    </slot>
  </b-modal>
</template>
