<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import GeoDesignsFilterBar from './geo_designs_filter_bar.vue';
import GeoDesigns from './geo_designs.vue';

export default {
  name: 'GeoDesignsApp',
  components: {
    GlLoadingIcon,
    GeoDesignsFilterBar,
    GeoDesigns,
  },
  props: {
    geoDesignsPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['isLoading']),
  },
  created() {
    this.setEndpoint(this.geoDesignsPath);
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
      <geo-designs v-else />
    </section>
  </article>
</template>
