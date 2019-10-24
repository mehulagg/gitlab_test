<script>
import { mapActions } from 'vuex';
import GeoDesignsFilterBar from './geo_designs_filter_bar.vue';
import GeoDesigns from './geo_designs.vue';

export default {
  name: 'GeoDesignsApp',
  components: {
    GeoDesignsFilterBar,
    GeoDesigns,
  },
  props: {
    geoDesignsPath: {
      type: String,
      required: true,
    },
  },
  created() {
    this.setEndpoint(this.geoDesignsPath);
    // this.fetchDesigns();
  },
  methods: {
    ...mapActions(['setEndpoint', 'fetchDesigns']),
  },
};
</script>

<template>
  <article class="geo-designs-container">
    <geo-designs-filter-bar />
    <geo-designs />
  </article>
</template>
