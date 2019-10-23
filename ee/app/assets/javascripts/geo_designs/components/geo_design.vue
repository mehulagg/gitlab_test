<script>
  // Using this for now, but might need to wrap into a new GlCard.
  // eslint-disable-next-line import/no-extraneous-dependencies
  import { BCard, BCardHeader, BCardBody } from 'bootstrap-vue'
  import { GlLink, GlButton } from '@gitlab/ui';

  export default {
    name: 'GeoDesign',
    components: {
      BCard,
      BCardHeader,
      BCardBody,
      GlLink,
      GlButton
    },
    props: {
      design: {
        type: Object,
        required: true
      }
    },
    data() {
      return {
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
          <p>{{ __("Success") }}</p>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Last successful sync") }}</label>
          <p>{{ __("2 days ago") }}</p>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Last time verified") }}</label>
          <p>{{ __("2 days ago") }}</p>
        </div>
        <div class="flex-grow-1">
          <label class="text-muted">{{ __("Last repository check run") }}</label>
          <p>{{ __("1 day ago") }}</p>
        </div>
      </div>
    </b-card-body>
  </b-card>
</template>