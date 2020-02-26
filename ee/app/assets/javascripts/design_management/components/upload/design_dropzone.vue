<script>
import { GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import createFlash from '~/flash';
import uploadDesignMutation from '../../graphql/mutations/uploadDesign.mutation.graphql';
import { UPLOAD_DESIGN_INVALID_FILETYPE_ERROR } from '../../utils/error_messages';
import { isValidDesignFile, VALID_DESIGN_FILE_MIMETYPE } from '../../utils/design_management_utils';

// https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/types
const VALID_DATA_TRANSFER_TYPE = 'Files';

export default {
  components: {
    GlIcon,
    GlLink,
    GlSprintf,
  },
  data() {
    return {
      dragging: false,
      isDragDataValid: false,
    };
  },
  methods: {
    isValidUpload(files) {
      return !files.some(file => !isValidDesignFile(file));
    },
    isValidDragDataType(e) {
      return !e.dataTransfer.types.some(t => t !== VALID_DATA_TRANSFER_TYPE);
    },
    ondrop(e) {
      this.dragging = false;

      const files = Array.from(e.dataTransfer.files);
      if (!files) {
        return;
      }
      // Do not createFlash, as the user already has feedback when dropzone is active
      if (!this.isDragDataValid) {
        return;
      }
      if (!this.isValidUpload(files)) {
        createFlash(UPLOAD_DESIGN_INVALID_FILETYPE_ERROR);
        return;
      }

      this.$emit('upload', e.dataTransfer.files);
    },
    ondragenter(e) {
      this.dragging = true;
      this.isDragDataValid = this.isValidDragDataType(e);
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
  VALID_DESIGN_FILE_MIMETYPE,
};
</script>

<template>
  <div
    class="w-100 position-relative"
    @drag.prevent.stop
    @dragstart.prevent.stop
    @dragend.prevent.stop="ondragleave"
    @dragleave.prevent.stop="ondragleave"
    @dragover.prevent.stop="ondragenter"
    @dragenter.prevent.stop="ondragenter"
    @drop.prevent.stop="ondrop"
  >
    <slot>
      <div class="card design-dropzone--border w-100 h-100 d-flex-center p-3">
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
        :accept="$options.VALID_DESIGN_FILE_MIMETYPE.mimetype"
        class="hide"
        @change="onFileUploadChange"
      />
    </slot>
    <transition name="design-dropzone-fade">
      <div
        v-show="dragging"
        class="card design-dropzone--border design-dropzone--overlay w-100 h-100 position-absolute d-flex-center p-3 bg-white"
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
    </transition>
  </div>
</template>
