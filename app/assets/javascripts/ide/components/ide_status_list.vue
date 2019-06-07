<script>
import { mapGetters } from 'vuex';

export default {
  computed: {
    ...mapGetters({
      file: 'activeFile',
    }),
  },
};
</script>

<template>
  <div class="ide-status-list d-flex">
    <template v-if="file">
      <div class="ide-status-file">{{ file.name }}</div>
      <div class="ide-status-file">{{ file.eol }}</div>
      <div v-if="!file.binary" class="ide-status-file">
        {{ file.editorRow }}:{{ file.editorColumn }}
      </div>
      <div class="ide-status-file">{{ file.fileLanguage }}</div>
    </template>
    <slot></slot>
  </div>
</template>
