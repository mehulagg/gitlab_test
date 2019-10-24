<script>
  import GeoDesign from './geo_design.vue'
  import { __ } from '~/locale';

  export default {
    name: 'GeoDesigns',
    components: {
      GeoDesign
    },
    data() {
      return {
        designs: [
          {
            id: 1,
            name: __('Zack\'s Design Repo'),
            url: 'http://localhost:3002',
            status: 'in_sync',
            last_synced_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
            last_verified_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
            last_checked_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
          },
          {
            id: 2,
            name: __('Valery\'s Design Repo'),
            url: 'http://localhost:3002',
            status: 'pending',
            last_synced_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
            last_verified_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
            last_checked_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
          },
          {
            id: 3,
            name: __('Mike\'s Design Repo'),
            url: 'http://localhost:3002',
            status: 'failed',
            last_synced_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
            last_verified_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
            last_checked_at: new Date(new Date(2019, 0, 1).getTime() + Math.random() * (new Date().getTime() - new Date(2019, 0, 1).getTime())),
          },
          {
            id: 4,
            name: __('Rachel\'s Design Repo'),
            url: 'http://localhost:3002',
            status: null,
            last_synced_at: null,
            last_verified_at: null,
            last_checked_at: null,
          },
        ]
      }
    },
  }
</script>

<template>
  <section>
    <geo-design v-for="design in designs" :key="design.id" :design="design" />
  </section>
</template>