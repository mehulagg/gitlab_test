<script>
import { GlListItem } from './../components';

export default {
  components: {
    GlListItem,
  },
  data: function() {
    return {
      items: [],
    };
  },
  mounted() {
    this.fetchIncidents();
  },
  methods: {
    fetchIncidents() {
      return fetch('./mock.json')
        .then(response => {
          if (!response.ok) throw new Error(response.status);
          else return response.json();
        })
        .then(data => {
          this.items = data;
        })
        .catch(error => {
          console.log('error: ' + error);
        });
    },
  },
};
</script>

<template>
  <div class="container">
    <h2>Incidents</h2>

    <div class="incident-list">
      <div v-for="item in items" :key="item.id" class="gl-border-1 p-3 incident-list-item">
        <gl-list-item :item="item"/>
      </div>
    </div>

  </div>
</template>

<style scoped lang="scss">
  .incident-list {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-gap: 16px;

    &-item {
      border-radius: 4px;
    }
  }
</style>
