<script>
import createFlash from '~/flash';
import uploadDesignMutation from '../../graphql/mutations/uploadDesign.mutation.graphql';
import { UPLOAD_DESIGN_INVALID_FILETYPE_ERROR } from '../../utils/error_messages';
import { GlIcon, GlLink, GlSprintf } from '@gitlab/ui';

// WARNING: replace this with something
// more sensical as per https://gitlab.com/gitlab-org/gitlab/issues/118611
const VALID_FILE_MIMETYPE = {
  mimetype: 'image/*',
  regex: /image\/.+/,
};

// https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/types
const VALID_DATA_TRANSFER_TYPE = 'Files';

export default {
  components: {
    GlIcon,
    GlLink,
    GlSprintf,
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
      return this.dragging
        ? {
            background: 'rbga(255, 255, 255, 0.5)',
          }
        : {};
    },
  },
  methods: {
    validFileTypes(files) {
      return !files.some(({ type }) => (type.match(VALID_FILE_MIMETYPE.regex) || []).length === 0);
    },
    validDragDataType(e) {
      return !e.dataTransfer.types.some(t => t !== VALID_DATA_TRANSFER_TYPE);
    },
    ondrop(e) {
      this.dragging = false;
      const files = Array.from(e.dataTransfer.files);

      if (!files) {
        return;
      }

      // TODO(tom) get clarification of UX
      if (files.length > this.maxFiles) {
        return;
      }

      // Do not createFlash as the user already has feedback when dropzone is active
      if (!this.isDragDataValid) {
        return;
      }

      if (!this.validFileTypes(files)) {
        createFlash(UPLOAD_DESIGN_INVALID_FILETYPE_ERROR);
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
          <div class="d-flex-center flex-column text-center">
            <gl-icon name="doc-new" :size="48" class="mb-4" />
            <p>
              <gl-sprintf
                :message="
                  __(
                    '%{lineOneStart}Drag and drop to upload your designs%{lineOneEnd} or %{linkStart}click to upload%{linkEnd}.',
                  )
                "
              >
                <template #lineOne="{ content }"
                  ><span class="d-block">{{ content }}</span>
                </template>

                <template #link="{ content }">
                  <gl-link class="h-100 w-100" @click="openFileUpload">{{ content }}</gl-link>
                </template>
              </gl-sprintf>
            </p>
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
        v-show="dragging"
        class="design-dropzone--overlay border-design-dropzone w-100 h-100 position-absolute d-flex-center"
      >
        <div v-show="!isDragDataValid" class="mw-50 text-center">
          <h3>{{ __('Oh no!') }}</h3>
          <span>{{ __('You can only drop image files here.') }}</span>
        </div>
        <div v-show="isDragDataValid" class="mw-50 text-center">
          <h3>{{ __('Incoming!') }}</h3>
          <span>{{ __('Drop your designs to start your upload.') }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
