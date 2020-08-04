<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { GlDrawer } from '@gitlab/ui';
import { inactiveId, sidebarTypes } from '~/boards/constants';

export default {
  headerHeight: process.env.NODE_ENV === 'development' ? '75px' : '40px',
  components: {
    GlDrawer,
  },
  mixins: [glFeatureFlagMixin()],
  computed: {
    ...mapGetters(['isSidebarOpen']),
    ...mapState(['isShowingEpicsSwimlanes', 'activeId', 'sidebarType']),
    isSwimlanesOn() {
      return this.glFeatures.boardsWithSwimlanes && this.isShowingEpicsSwimlanes;
    },
    showSidebar() {
      return this.isSwimlanesOn && this.sidebarType === sidebarTypes.issuable;
    },
  },
  methods: {
    ...mapActions(['setActiveId']),
    closeSidebar() {
      this.setActiveId({ id: inactiveId });
    },
  },
};
</script>

<template>
  <gl-drawer
    v-if="showSidebar"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="closeSidebar"
  />
</template>
