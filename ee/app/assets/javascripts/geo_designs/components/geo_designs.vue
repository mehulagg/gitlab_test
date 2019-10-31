<script>
import { mapGetters, mapState, mapActions } from 'vuex';
import { GlPagination } from '@gitlab/ui';
import GeoDesign from './geo_design.vue';

export default {
  name: 'GeoDesigns',
  components: {
    GlPagination,
    GeoDesign,
  },
  computed: {
    ...mapGetters({
      designs: 'getDesignsByFilter',
    }),
    ...mapState(['totalDesigns', 'currentPage', 'pageSize']),
     page: {
      get() {
        return this.currentPage;
      },
      set(newVal) {
        this.setPage(newVal);
      },
     },
  },
  methods: {
    ...mapActions(['setPage']),
  }
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
    <gl-pagination v-model="page" :per-page="pageSize" :total-items="totalDesigns" align="center" />
  </section>
</template>
