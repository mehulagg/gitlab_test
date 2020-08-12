<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { GlDrawer } from '@gitlab/ui';
import { ISSUABLE } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';
import EpicSelector from './sidebar/epic_selector.vue'

export default {
  headerHeight: `${contentTop()}px`,
  components: {
    GlDrawer,
    EpicSelector,
  },
  mixins: [glFeatureFlagMixin()],
  computed: {
    ...mapGetters(['isSidebarOpen']),
    ...mapState(['sidebarType']),
    showSidebar() {
      return this.sidebarType === ISSUABLE;
    },
  },
  methods: {
    ...mapActions(['unsetActiveId']),
  },
};
</script>

<template>
  <gl-drawer
    v-if="showSidebar"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="unsetActiveId"
  >
    <template>
      <epic-selector />
    </template>
  </gl-drawer>
</template>
