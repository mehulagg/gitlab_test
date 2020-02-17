<script>
  import GlButton from '@gitlab/ui/dist/components/base/button/button';
  import GlBadge from '@gitlab/ui/dist/components/base/badge/badge';

  export default {
    components: {
      GlButton,
      GlBadge,
    },
    props: {
      item: {
        type: Object,
        required: true,
      }
    },
    data: function () {
      return {}
    },
    computed: {},
    methods: {
      getDateFormatted(date) {
        const options = {year: 'numeric', month: 'long', day: 'numeric'};
        return (new Date()).toLocaleDateString(undefined, options);
      },
      getStatusVariant(status) {
        return status === 'open' ? 'danger' : 'success';
      },
    },
  }
</script>

<template>
  <div>
    <strong>{{getDateFormatted(item.title)}}</strong>
    <div class="text-secondary">{{item.title}}</div>
    <div class="text-status">
      <gl-badge pill :variant="getStatusVariant(item.status)">{{item.status}}</gl-badge>
      : <strong>{{item.service}}</strong> is operating normally.
    </div>
    <router-link :to="{ name: 'details', params: { id: item.id } }">
      <gl-button variant="outline-info mt-4">Full report</gl-button>
    </router-link>
  </div>
</template>

<style scoped lang="scss">
  .text-secondary {
    color: $gl-text-color-secondary !important;
  }
</style>
