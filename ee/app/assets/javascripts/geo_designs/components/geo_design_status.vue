<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'GeoDesignStatus',
  components: {
    Icon,
  },
  props: {
    status: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    icon() {
      if (this.status === 'synced') {
        return {
          name: 'status_closed',
          colorClass: 'text-success',
        };
      }
      if (this.status === 'pending') {
        return {
          name: 'status_scheduled',
          colorClass: 'text-warning',
        };
      }
      if (this.status === 'failed') {
        return {
          name: 'status_failed',
          colorClass: 'text-danger',
        };
      }

      return {
        name: 'status_notfound',
        colorClass: 'text-muted',
      };
    },
  },
};
</script>

<template>
  <div>
    <span class="d-flex align-items-center text-capitalize">
      <icon :name="icon.name" :class="icon.colorClass" class="mr-2" />
      {{ status || 'never' }}
    </span>
  </div>
</template>