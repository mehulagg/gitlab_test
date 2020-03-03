<script>
import ItemButton from './button.vue';
import { languages } from 'monaco-editor';

const monacoLanguages = languages.getLanguages();

export default {
  components: {
    ItemButton,
  },
  props: {
    path: {
      type: String,
      required: false,
      default: '',
    },
    showLabel: {
      type: Boolean,
      required: false,
      default: true,
    },
    buttonCssClasses: {
      type: String,
      required: false,
      default: null,
    },
  },
  methods: {
    isText(content, fileType, fileName) {
      const knownBinaryFileTypes = ['image/'];
      const isKnownBinaryFileType = knownBinaryFileTypes.find(type => fileType.includes(type));
      if (isKnownBinaryFileType) return false;

      const knownTextFileTypes = ['text/'];
      const isKnownTextFileType = knownTextFileTypes.find(type => fileType.includes(type));
      if (isKnownTextFileType) return true;

      // If Monaco supports syntax highlighting for this file, it is a text file for sure
      const fileExtension = `.${fileName.split('.').pop()}`;
      const isSupportedByMonaco = monacoLanguages.some(
        lang =>
          lang.extensions?.some(extension => extension === fileExtension) ||
          lang.mimetypes?.some(type => type === fileType),
      );
      if (isSupportedByMonaco) return true;

      const asciiRegex = /^[ -~\t\n\r]+$/; // tests whether a string contains ascii characters only (ranges from space to tilde, tabs and new lines)
      // finally, determine the type by evaluating the file contents
      return asciiRegex.test(content);
    },

    createFile(target, file) {
      const { name } = file;
      const encodedContent = target.result.split('base64,')[1];
      const rawContent = encodedContent ? atob(encodedContent) : '';
      const isText = this.isText(rawContent, file.type, name);

      const emitCreateEvent = content =>
        this.$emit('create', {
          name: `${this.path ? `${this.path}/` : ''}${name}`,
          type: 'blob',
          content,
          base64: !isText,
          binary: !isText,
          rawPath: !isText ? target.result : '',
        });

      if (isText) {
        const reader = new FileReader();

        reader.addEventListener('load', e => emitCreateEvent(e.target.result), { once: true });
        reader.readAsText(file);
      } else {
        emitCreateEvent(encodedContent);
      }
    },
    readFile(file) {
      const reader = new FileReader();

      reader.addEventListener('load', e => this.createFile(e.target, file), { once: true });
      reader.readAsDataURL(file);
    },
    openFile() {
      Array.from(this.$refs.fileUpload.files).forEach(file => this.readFile(file));
    },
    startFileUpload() {
      this.$refs.fileUpload.click();
    },
  },
};
</script>

<template>
  <div>
    <item-button
      :class="buttonCssClasses"
      :show-label="showLabel"
      :icon-classes="showLabel ? 'mr-2' : ''"
      :label="__('Upload file')"
      class="d-flex"
      icon="upload"
      @click="startFileUpload"
    />
    <input
      id="file-upload"
      ref="fileUpload"
      type="file"
      class="hidden"
      multiple
      @change="openFile"
    />
  </div>
</template>
