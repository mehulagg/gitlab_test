<script>
  // Using this for now, but might need to wrap into a new GlCard.
  // eslint-disable-next-line import/no-extraneous-dependencies
  import { BCard, BCardHeader, BCardBody } from 'bootstrap-vue'
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
      GeoDesignStatus
    },
    props: {
      design: {
        type: Object,
        required: true
      }
    },
  }
</script>

<template>
  <b-card no-body>
    <b-card-header class="d-flex align-center">
      <gl-link class="font-weight-bold" :href="design.url" target="_blank">{{ design.name }}</gl-link>
      <div class="ml-auto">
        <gl-button>{{ __("Reverify") }}</gl-button>
        <gl-button>{{ __("Resync") }}</gl-button>
      </div>
    </b-card-header>
    <b-card-body>
      <div class="d-flex flex-column flex-md-row">
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Status") }}</label>
          <geo-design-status :status="design.sync_status" />
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Last successful sync") }}</label>
          <div>
            <time-ago
              v-if="design.last_synced_at"
              :time="design.last_synced_at.toString()"
              tooltip-placement="bottom"
              class="js-timeago"
            />
            <span v-else>{{ __("Never") }}</span>
          </div>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Last time verified") }}</label>
          <div>
            <time-ago
              v-if="design.last_verified_at"
              :time="design.last_verified_at.toString()"
              tooltip-placement="bottom"
              class="js-timeago"
            />
            <span v-else>{{ __("Never") }}</span>
          </div>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Last repository check run") }}</label>
          <div>
            <time-ago
              v-if="design.last_checked_at"
              :time="design.last_checked_at.toString()"
              tooltip-placement="bottom"
              class="js-timeago"
            />
            <span v-else>{{ __("Never") }}</span>
          </div>
        </div>
      </div>
    </b-card-body>
  </b-card>
</template>