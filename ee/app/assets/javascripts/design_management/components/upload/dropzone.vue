<script>
import uploadDesignMutation from '../../graphql/mutations/uploadDesign.mutation.graphql';
import { GlIcon, GlLink } from '@gitlab/ui';

// WARNING: replace this with something
// more sensical as per https://gitlab.com/gitlab-org/gitlab/issues/118611
const VALID_FILE_MIMETYPE = {
  mimetype: 'image/*',
  regex: /image\/.+/,
};

export default {
  components: {
    GlIcon,
    GlLink,
  },
  props: {
    maxFiles: {
      type: Number,
      required: false,
      default: 1,
    },
  },
  data() {
    return {
      dragging: false,
      isDragDataValid: false,
    };
  },
  computed: {
    dropzoneStyle() {
      if (this.dragging) {
        return {
          background: 'rbga(255, 255, 255, 0.5)',
        };
      }
    },
  },
  methods: {
    validFileTypes(files) {
      return !files.some(({ type }) => type.match(VALID_FILE_MIMETYPE.regex).length !== 1);
    },
    validDragDataType(e) {
      return !e.dataTransfer.types.some(t => t !== 'Files');
    },
    ondrop(e) {
      this.dragging = false;

      const files = Array.from(e.dataTransfer.files);

      if (files.length > this.maxFiles) {
        console.error('too many files');
        return;
      }

      if (!this.isDragDataValid || !this.validFileTypes(files)) {
        console.error('invalid drag data');
        return;
      }

      this.$emit('upload', e.dataTransfer.files);
    },
    ondragenter(e) {
      this.dragging = true;
      this.isDragDataValid = this.validDragDataType(e);
    },
    ondragleave() {
      this.dragging = false;
    },
    openFileUpload() {
      this.$refs.fileUpload.click();
    },
    onFileUploadChange() {
      this.$emit('upload', this.$refs.fileUpload.files);
    },
  },
  uploadDesignMutation,
  VALID_FILE_MIMETYPE,
};
</script>

<template>
  <div
    ref="dropzone"
    @drag.prevent.stop
    @dragstart.prevent.stop
    @dragend.prevent.stop="ondragleave"
    @dragleave.prevent.stop="ondragleave"
    @dragover.prevent.stop="ondragenter"
    @dragenter.prevent.stop="ondragenter"
    @drop.prevent.stop="ondrop"
  >
    <div class="w-100 h-100 position-relative">
      <slot v-bind="{ dragging, isDragDataValid }">
        <div class="border-design-dropzone w-100 h-100 d-flex-center rounded-sm">
          <div class="d-flex-center flex-column">
            <gl-icon name="doc-new" :size="48" class="mb-4" />
            <span>Drag and drop to upload your designs</span>
            <span
              >or
              <gl-link class="h-100 w-100" @click="openFileUpload">click to upload</gl-link>.</span
            >
          </div>
        </div>
        <input
          ref="fileUpload"
          type="file"
          name="design_file"
          :accept="$options.VALID_FILE_MIMETYPE.type"
          class="hide"
          @change="onFileUploadChange"
        />
      </slot>
      <div
        class="design-dropzone--overlay border-design-dropzone w-100 h-100 position-absolute d-flex-center"
        v-show="dragging"
      >
        <div class="mw-50 text-center">
          <template v-show="isDragDataValid">
            <h3>Oh no!</h3>
            <span>You can only drop image files here.</span>
          </template>
          <template v-show="!isDragDataValid">
            <h3>Incoming!</h3>
            <span>Drop your designs to start your upload.</span>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>
