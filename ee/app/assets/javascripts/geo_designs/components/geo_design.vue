<script>
// Using this for now, but might need to wrap into a new GlCard.
// eslint-disable-next-line import/no-extraneous-dependencies
import { BCard, BCardHeader, BCardBody } from 'bootstrap-vue';
import { GlLink, GlButton } from '@gitlab/ui';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import GeoDesignStatus from './geo_design_status.vue';

export default {
  name: 'GeoDesign',
  components: {
    BCard,
    BCardHeader,
    BCardBody,
    GlLink,
    GlButton,
    TimeAgo,
    GeoDesignStatus,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: true,
    },
    syncStatus: {
      type: String,
      required: false,
      default: null,
    },
    lastSynced: {
      type: String,
      required: false,
      default: null,
    },
    lastVerified: {
      type: String,
      required: false,
      default: null,
    },
    lastChecked: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <b-card no-body>
    <b-card-header class="d-flex align-center">
      <gl-link class="font-weight-bold" :href="url" target="_blank">{{ name }}</gl-link>
      <div class="ml-auto">
        <gl-button>{{ __('Reverify') }}</gl-button>
        <gl-button>{{ __('Resync') }}</gl-button>
      </div>
    </b-card-header>
    <b-card-body>
      <div class="d-flex flex-column flex-md-row">
        <div class="flex-grow-1">
          <label class="text-muted">{{ __('Status') }}</label>
          <geo-design-status :status="syncStatus" />
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __('Last successful sync') }}</label>
          <div>
            <time-ago
              v-if="lastSynced"
              :time="lastSynced"
              tooltip-placement="bottom"
              class="js-timeago"
            />
            <span v-else>{{ __('Never') }}</span>
          </div>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __('Last time verified') }}</label>
          <div>
            <time-ago
              v-if="lastVerified"
              :time="lastVerified"
              tooltip-placement="bottom"
              class="js-timeago"
            />
            <span v-else>{{ __('Never') }}</span>
          </div>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __('Last repository check run') }}</label>
          <div>
            <time-ago
              v-if="lastChecked"
              :time="lastChecked"
              tooltip-placement="bottom"
              class="js-timeago"
            />
            <span v-else>{{ __('Never') }}</span>
          </div>
        </div>
      </div>
    </b-card-body>
  </b-card>
</template>
