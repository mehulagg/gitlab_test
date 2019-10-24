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
            status: 'in_sync'
          },
          {
            id: 2,
            name: __('Valery\'s Design Repo'),
            url: 'http://localhost:3002',
            status: 'pending'
          },
          {
            id: 3,
            name: __('Mike\'s Design Repo'),
            url: 'http://localhost:3002',
            status: 'failed'
          },
          {
            id: 4,
            name: __('Rachel\'s Design Repo'),
            url: 'http://localhost:3002',
            status: null
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