<script>
import App from '../app.vue';
import ProjectRules from './project_rules.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: {
    App,
    ProjectRules,
  },
  mixins: [glFeatureFlagsMixin()],
};
</script>

<template>
  <app :is-mr-edit="false"><project-rules slot="rules"/></app>
</template>
