<script>
  import Icon from '~/vue_shared/components/icon.vue';
  import { __ } from '~/locale';

  export default {
    name: "GeoDesignStatus",
    components: {
      Icon
    },
    props: {
      status: {
        type: String,
        required: true
      },
    },
    computed: {
      statusName() {
        if (this.status) {
          // ex. in_sync === In sync
          return this.status[0].toUpperCase() + this.status.slice(1).split('_').join(' ');
        }

        return __('Never');
      },
      icon() {
        if (this.status === 'in_sync') {
          return {
            name: 'status_closed',
            colorClass: 'text-success'
          }
        }
        if (this.status === 'pending') {
          return {
            name: 'status_scheduled',
            colorClass: 'text-warning'
          }
        }
        if (this.status === 'failed') {
          return {
            name: 'status_failed',
            colorClass: 'text-danger'
          }
        }

        return {
          name: 'status_notfound',
          colorClass: 'text-muted'
        }
      }
    }
  }
</script>

<template>
  <div>
    <span class="d-flex align-items-center"><icon :name="icon.name" :class="icon.colorClass" class="mr-2"/> {{ statusName }}</span>
  </div>
</template>