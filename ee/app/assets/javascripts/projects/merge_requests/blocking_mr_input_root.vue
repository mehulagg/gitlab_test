<script>
import RelatedIssuableInput from 'ee/related_issues/components/related_issuable_input.vue';
import { __ } from '~/locale';

export default {
  components: {
    RelatedIssuableInput,
  },
  props: {
    existingRefs: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      references: this.existingRefs,
      inputValue: '',
    };
  },
  computed: {
    inputPlaceholder() {
      return __('Blocking merge requests')
    }
  },
  methods: {
    onAddIssuable({ untouchedRawReferences, touchedReference }) {
      this.references = [...this.references, untouchedRawReferences];
      this.inputValue = touchedReference;
    },
    onPendingIssuableRemoveRequest(index) {
      console.log(index);
      this.references.splice(index, 1);
    },
  },
};
</script>

<template>
  <related-issuable-input
    path-id-separator="!"
    :references="references"
    :input-placeholder="inputPlaceholder"
    :on-pending-issuable-remove-request="onPendingIssuableRemoveRequest"
    @addIssuableFormInput="onAddIssuable"
  />
</template>
