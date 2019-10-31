<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';

export default {
  name: 'GeoEmptyState',
  components: {
    GlEmptyState,
    GlLink,
  },
};
</script>

<template>
  <gl-empty-state :title="__('No Design Repositories match this filter')" svg-path="https://gitlab.com/gitlab-org/gitlab-svgs/raw/master/illustrations/issues.svg">
    <template v-slot:description>
      <div class="text-center">
        <p>{{ __("Adjust your filters/search criteria above.") }}</p>
        <p>
          {{ __("If you believe this may be an error, please refer to the") }}
          <gl-link href="https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html" target="_blank">{{ __("Geo Troubleshooting") }}</gl-link>
          {{ __("documentation for more information.") }}
        </p>
      </div>
    </template>
  </gl-empty-state>
</template>