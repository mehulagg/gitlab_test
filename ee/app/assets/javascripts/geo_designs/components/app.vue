<script>
import GeoDesignsFilterBar from './geo_designs_filter_bar.vue'
import GeoDesigns from './geo_designs.vue'

export default {
  name: 'GeoDesignsApp',
  components: {
    GeoDesignsFilterBar,
    GeoDesigns
  },
  props: {
    /*
    store: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
    */
  },
  data() {
    return {};
  },
};
</script>

<template>
  <article class="geo-designs-container">
    <geo-designs-filter-bar />
    <geo-designs />
  </article>
</template>
