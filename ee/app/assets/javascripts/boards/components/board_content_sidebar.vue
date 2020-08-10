<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { GlDrawer } from '@gitlab/ui';
import { sidebarTypes } from '~/boards/constants';
import { contentTop } from '~/lib/utils/common_utils';

export default {
  headerHeight: `${contentTop()}px`,
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
  />
</template>
