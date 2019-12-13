<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'FileRow',
  components: {
    Icon,
  },
  props: {
    file: {
      type: Object,
      required: true,
    },
    level: {
      type: Number,
      required: true,
    },
  },
};
</script>

<template functional>
  <div>
    <div
      v-if="props.file.isHeader"
      class="file-row-header bg-white sticky-top p-2 js-file-row-header"
    >
      <span class="bold">{{ props.file.path }}</span>
    </div>
    <div
      v-else
      :title="props.file.name"
      :class="{
        folder: props.file.type === 'tree',
      }"
      class="file-row"
      role="button"
    >
      <div class="file-row-name-container">
        <span
          ref="textOutput"
          :style="{
            marginLeft: props.level ? `${props.level * 16}px` : null,
          }"
          class="file-row-name str-truncated"
        >
          <span class="file-changed-icon d-inline-block append-right-5">
            <icon
              :name="props.file.icon"
              :size="16"
              :class="[props.file.icon, 'float-left d-block']"
            />
          </span>
          {{ props.file.name }}
        </span>
        <span v-if="props.file.type !== 'tree'" class="file-row-stats">
          <span class="cgreen"> +{{ props.file.addedLines }} </span>
          <span class="cred"> -{{ props.file.removedLines }} </span>
        </span>
      </div>
    </div>
    <template v-if="props.file.isHeader">
      <file-row
        v-for="childFile in props.file.tree"
        :key="childFile.key"
        :file="childFile"
        :level="props.file.isHeader ? 0 : props.level + 1"
      />
    </template>
  </div>
</template>

<style>
.file-row {
  display: flex;
  align-items: center;
  height: 32px;
  padding: 4px 8px;
  margin-left: -8px;
  margin-right: -8px;
  border-radius: 3px;
  text-align: left;
  cursor: pointer;
}

.file-row:hover,
.file-row:focus {
  background: #f2f2f2;
}

.file-row:active {
  background: #dfdfdf;
}

.file-row.is-active {
  background: #f2f2f2;
}

.file-row-name-container {
  display: flex;
  width: 100%;
  align-items: center;
  overflow: visible;
}

.file-row-name {
  display: inline-block;
  flex: 1;
  max-width: inherit;
  height: 19px;
  line-height: 16px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.file-row-name .file-row-icon {
  margin-right: 2px;
  vertical-align: middle;
}
</style>
