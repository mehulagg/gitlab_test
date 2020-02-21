<script>
import uploadDesignMutation from '../../graphql/mutations/uploadDesign.mutation.graphql';

// WARNING: replace this with something
// more sensical as per https://gitlab.com/gitlab-org/gitlab/issues/118611
const VALID_FILE_MIMETYPE = {
  mimetype: 'image/*',
  regex: /image\/.+/,
};

export default {
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
      const baseStyle = {
        width: '200px',
        height: '200px',
        border: '1px solid grey',
      };
      if (this.dragging) {
        baseStyle.border = '1px solid red';
      }

      return baseStyle;
    },
  },
  methods: {
    validFileTypes(files) {
      return !files.some(({ type }) => type.match(VALID_FILE_MIMETYPE.regex).length === 1);
    },
    validDragDataType(e) {
      return !e.dataTransfer.types.some(t => t !== 'Files');
    },
    ondrop(e) {
      this.dragging = false;

      const files = Array.from(e.dataTransfer.files);
      console.log('e.dataTransfer', e.dataTransfer.types);

      if (files.length > this.maxFiles) {
        console.error('too many files');
        return;
      }

      if (!this.isDragDataValid || !validFileTypes(files)) {
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
  mounted() {},
  uploadDesignMutation,
  VALID_FILE_MIMETYPE,
};
</script>

<template>
  <button
    ref="dropzone"
    :style="dropzoneStyle"
    @drag.prevent.stop
    @dragstart.prevent.stop
    @dragend.prevent.stop="ondragleave"
    @dragleave.prevent.stop="ondragleave"
    @dragover.prevent.stop="ondragenter"
    @dragenter.prevent.stop="ondragenter"
    @drop.prevent.stop="ondrop"
    @click="openFileUpload"
  >
    <input
      ref="fileUpload"
      type="file"
      name="design_file"
      :accept="$options.VALID_FILE_MIMETYPE.type"
      class="hide"
      @change="onFileUploadChange"
    />
    <slot v-bind="{ dragging, isDragDataValid }"></slot>
  </button>
</template>
