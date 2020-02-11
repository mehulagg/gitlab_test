<script>
import { GlCard } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'GeoBlobRegistry',
  components: {
    GlCard,
    Icon,
  },
  props: {
    blob: {
      type: Object,
      required: true,
    },
  },
  methods: {
    iconName(status) {
      if (status === 'synced') {
        return 'status_success';
      } else if (status === 'pending') {
        return 'status_scheduled';
      } else if (status === 'failed') {
        return 'status_failed';
      }

      return 'status_notfound';
    },
    iconClass(status) {
      if (status === 'synced') {
        return 'text-success';
      } else if (status === 'pending') {
        return 'text-warning';
      } else if (status === 'failed') {
        return 'text-danger';
      }

      return 'text-muted';
    },
  },
};
</script>

<template>
  <div>
    <h4>{{ __(`Tracking entries for ${blob.name}`) }}</h4>
    <gl-card v-for="entry in blob.entries.nodes" :key="entry.iid">
      <div class="d-flex align-items-center">
        <span class="d-flex align-items-center text-capitalize mr-5">
          <icon
            :name="iconName(entry.sync_status)"
            :class="iconClass(entry.sync_status)"
            class="mr-2"
          />
          {{ entry.sync_status }}
        </span>
        <span class="font-weight-bold">{{ entry.title }}</span>
      </div>
    </gl-card>
  </div>
</template>

<style lang="scss" scoped></style>
