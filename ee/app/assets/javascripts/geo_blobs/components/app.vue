<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import GitlabProjects from './projects_example/gitlab_projects.vue';
import GeoBlobs from './geo_blobs.vue';

export default {
  name: 'GeoBlobsApp',
  components: {
    GlTabs,
    GlTab,
    GitlabProjects,
    GeoBlobs,
  },
};
</script>

<template>
  <article>
    <h1>{{ __('Geo using GraphQL Example') }}</h1>
    <gl-tabs>
      <gl-tab title="Mocked GraphQL (Blobs/Registries)"><geo-blobs /></gl-tab>
      <gl-tab title="Live GraphQL (Projects/Issues)"><gitlab-projects /></gl-tab>
    </gl-tabs>
  </article>
</template>

<style lang="scss" scoped></style>
