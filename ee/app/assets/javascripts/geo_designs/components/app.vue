<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import GeoDesignsFilterBar from './geo_designs_filter_bar.vue';
import GeoDesigns from './geo_designs.vue';
import GeoEmptyState from './geo_empty_state.vue'

export default {
  name: 'GeoDesignsApp',
  components: {
    GlLoadingIcon,
    GeoDesignsFilterBar,
    GeoDesigns,
    GeoEmptyState
  },
  computed: {
    ...mapState(['isLoading', 'totalDesigns']),
  },
  created() {
    this.setEndpoint();
    this.fetchDesigns();
  },
  methods: {
    ...mapActions(['setEndpoint', 'fetchDesigns']),
  },
};
</script>

<template>
  <article class="geo-designs-container">
    <geo-designs-filter-bar />
    <section>
      <gl-loading-icon v-if="isLoading" size="xl" />
      <section v-else>
        <geo-designs v-if="totalDesigns > 0" :total-designs="totalDesigns" />
        <geo-empty-state v-else />
      </section>
    </section>
  </article>
</template>
