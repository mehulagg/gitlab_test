<script>
import uploadDesignMutation from '../../graphql/mutations/uploadDesign.mutation.graphql';

const MAX_FILES = 1;

export default {
  props: {},
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
    ondrop(e) {
      this.dragging = false;

      const files = Array.from(e.dataTransfer.files);
      if (files.length > MAX_FILES) {
        console.error('too many files');
      }

      this.$emit('upload', e.dataTransfer.files);
    },
  },
  data() {
    return {
      dragging: false,
    };
  },
  mounted() {},
  uploadDesignMutation,
};
</script>

<template>
  <div
    ref="dropzone"
    :style="dropzoneStyle"
    @drag.prevent.stop
    @dragstart.prevent.stop
    @dragend.prevent.stop="dragging = false"
    @dragleave.prevent.stop="dragging = false"
    @dragover.prevent.stop="dragging = true"
    @dragenter.prevent.stop="dragging = true"
    @drop.prevent.stop="ondrop"
  >
    <input ref="fileUpload" type="file" name="files[]" accept="image/*" class="hide" />
    <slot></slot>
  </div>
</template>
