<script>
import { GlLoadingIcon } from '@gitlab/ui';
import BlobHeaderEdit from '~/blob/components/blob_edit_header.vue';
import BlobContentEdit from '~/blob/components/blob_edit_content.vue';
import { getBaseURL, joinPaths } from '~/lib/utils/url_utility';
import axios from '~/lib/utils/axios_utils';
import { SNIPPET_BLOB_CONTENT_FETCH_ERROR } from '~/snippets/constants';
import { deprecatedCreateFlash as Flash } from '~/flash';
import { sprintf } from '~/locale';

export default {
  components: {
    BlobHeaderEdit,
    BlobContentEdit,
    GlLoadingIcon,
  },
  inheritAttrs: false,
  props: {
    blob: {
      type: Object,
      required: true,
    },
    canDelete: {
      type: Boolean,
      required: false,
      default: true,
    },
    showDelete: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    inputId() {
      return `${this.blob.id}_file_path`;
    },
  },
  mounted() {
    if (!this.blob.isLoaded) {
      this.fetchBlobContent();
    }
  },
  methods: {
    onDelete() {
      this.$emit('delete');
    },
    notifyAboutUpdates(args = {}) {
      this.$emit('blob-updated', args);
    },
    fetchBlobContent() {
      const baseUrl = getBaseURL();
      const url = joinPaths(baseUrl, this.blob.rawPath);

      axios
        .get(url, {
          // This prevents axios from automatically JSON.parse response
          transformResponse: [f => f],
        })
        .then(res => {
          this.notifyAboutUpdates({ content: res.data });
        })
        .catch(e => this.flashAPIFailure(e));
    },
    flashAPIFailure(err) {
      Flash(sprintf(SNIPPET_BLOB_CONTENT_FETCH_ERROR, { err }));
    },
  },
};
</script>
<template>
  <div class="file-holder snippet">
    <blob-header-edit
      :id="inputId"
      :value="blob.path"
      data-qa-selector="file_name_field"
      :can-delete="canDelete"
      :show-delete="showDelete"
      @input="notifyAboutUpdates({ path: $event })"
      @delete="onDelete"
    />
    <gl-loading-icon
      v-if="!blob.isLoaded"
      :label="__('Loading snippet')"
      size="lg"
      class="loading-animation prepend-top-20 gl-mb-6"
    />
    <blob-content-edit
      v-else
      :value="blob.content"
      :file-global-id="blob.id"
      :file-name="blob.path"
      @input="notifyAboutUpdates({ content: $event })"
    />
  </div>
</template>
