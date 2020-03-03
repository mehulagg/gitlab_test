<script>
import { GlNewDropdown, GlNewDropdownItem } from '@gitlab/ui';
import { mapActions, mapGetters } from 'vuex';

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownItem,
  },
  methods: {
    ...mapActions([
      'fetchDiscussions',
    ]),
    fetchSortedDiscussions() {
      // do we need to do client side sort?
      this.fetchDiscussions({ sort : 'asc', path: this.getNotesDataByProp('discussionsPath') })
    },
  },
  computed: {
    ...mapGetters(['getNotesDataByProp']),
  }
};
</script>

<template>
  <gl-new-dropdown text="Some dropdown">
    <gl-new-dropdown-item @click="fetchSortedDiscussions">First item</gl-new-dropdown-item>
  </gl-new-dropdown>
</template>
