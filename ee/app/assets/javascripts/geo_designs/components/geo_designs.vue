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
      designs: 'getDesignsByFilter',
    }),
  },
};
</script>

<template>
  <section>
    <geo-design
      v-for="design in designs"
      :key="design.id"
      :name="design.name"
      :sync-status="design.state"
      :last-synced="design.last_synced_at"
      :last-verified="design.last_verified_at"
      :last-checked="design.last_checked_at"
    />
  </section>
</template>
