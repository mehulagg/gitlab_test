<script>
import MarkdownFieldView from '~/vue_shared/components/markdown/field_view.vue';
import ViewerMixin from './mixins';
import { handleBlobRichViewer } from '~/blob/viewer';

export default {
  components: {
    MarkdownFieldView,
  },
  mixins: [ViewerMixin],
  mounted() {
    handleBlobRichViewer(this.$refs.content, this.type);
  },
};
</script>
<template>
  <!-- eslint-disable vue/no-v-html -->
  <markdown-field-view ref="content" v-html="content" />
  <!-- eslint-enable vue/no-v-html -->
</template>
