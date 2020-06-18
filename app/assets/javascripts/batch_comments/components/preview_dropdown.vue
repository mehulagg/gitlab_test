<script>
import { mapActions, mapGetters } from 'vuex';
import { GlNewDropdown, GlNewDropdownItem, GlIcon } from '@gitlab/ui';
import PreviewItem from './preview_item.vue';

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownItem,
    GlIcon,
    PreviewItem,
  },
  computed: {
    ...mapGetters('batchComments', ['draftsCount', 'sortedDrafts']),
  },
  methods: {
    ...mapActions('batchComments', ['scrollToDraft']),
    isLast(index) {
      return index === this.sortedDrafts.length - 1;
    },
  },
};
</script>

<template>
  <gl-new-dropdown
    :header-text="n__('%d pending comment', '%d pending comments', draftsCount)"
    dropup
  >
    <template #button-content>
      {{ __('Pending comments') }}
      <gl-icon class="dropdown-chevron" name="chevron-up" />
    </template>
    <gl-new-dropdown-item
      v-for="(draft, index) in sortedDrafts"
      :key="draft.id"
      @click="scrollToDraft(draft)"
    >
      <preview-item :draft="draft" :is-last="isLast(index)" />
    </gl-new-dropdown-item>
  </gl-new-dropdown>
</template>
