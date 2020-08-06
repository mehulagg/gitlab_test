<script>
import { initEditorLite } from '../utils/utils';
import { debounce } from 'lodash';

export default {
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
    fileName: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      editor: null,
      blobContent: `
build_a:
  stage: build
  script: make
build_b:
  stage: build
  script: make
build_c:
  stage: build
  script: make
build_d:
  stage: build
  script: make
  parallel: 3
test_a:
  stage: test
  script: ls
  needs: [build_a, build_b, build_c]
test_b:
  stage: test
  script: ls
  parallel: 2
  needs: [build_a, build_b, build_d]
test_c:
  stage: test
  script: ls
  needs: [build_a, build_b, build_c]
`,
    };
  },
  watch: {
    fileName(newVal) {
      this.editor.updateModelLanguage(newVal);
    },
  },
  mounted() {
    this.editor = initEditorLite({
      el: this.$refs.editor,
      blobPath: this.fileName,
      blobContent: this.blobContent,
    });

    this.editor.instance.layout({
      height: this.editor.instance.getModel().getLineCount() * 19,
      width: 1000,
    });

    this.$emit('input', this.editor.getValue());
  },
  methods: {
    triggerFileChange: debounce(function debouncedFileChange() {
      this.$emit('input', this.editor.getValue());
    }, 250),
  },
};
</script>
<template>
  <div class="file-content code">
    <pre id="editor" ref="editor" data-editor-loading @keyup="triggerFileChange">{{ value }}</pre>
  </div>
</template>
