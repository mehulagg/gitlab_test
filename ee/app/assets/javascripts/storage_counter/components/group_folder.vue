<script>
import { omit } from 'lodash';
import GroupItem from './group_item.vue';

const KEYS_TO_IGNORE = ['id', 'projects', 'path'];

export default {
  name: 'group-folder',
  components: {
    GroupItem,
  },
  props: {
    group: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    getProjects() {
      return this.group.projects;
    },
    getSubGroups() {
      return omit(this.group, KEYS_TO_IGNORE);
    },
  },
};
</script>

<template>
  <ul class="groups-list group-list-tree">
    <group-item v-for="(project, index) in getProjects" :key="index" :project="project" />
    <li v-for="group in getSubGroups" :key="group.id" class="group-row">
      {{ group.id }}
      <group-folder :group="group" />
    </li>
  </ul>
</template>
