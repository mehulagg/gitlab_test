<script>
import { VALID_DESIGN_FILE_MIMETYPE } from '../../utils/design_management_utils';

export default {
  methods: {
    onFileUploadChange() {
      this.$emit('upload', this.$refs.designInput.files);
    },
  },
  VALID_DESIGN_FILE_MIMETYPE,
};
</script>

<template>
  <input
    ref="designInput"
    type="file"
    name="design_file"
    :accept="$options.VALID_DESIGN_FILE_MIMETYPE"
    class="hide"
    multiple
    @change="$emit('change', $event)"
  />
</template>
