<script>
import { mapGetters } from 'vuex';
import GeoDesign from './geo_design.vue';

export default {
  name: 'GeoDesigns',
  components: {
    GeoDesign,
  },
  computed: {
    ...mapGetters({
      designs: 'getDesignsByFilter'
    })
  }
};
</script>

<template>
  <section>
    <geo-design v-for="design in designs" :key="design.id" :design="design" />
  </section>
</template>