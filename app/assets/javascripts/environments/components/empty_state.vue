<script>
import glPathsMixin from '~/vue_shared/mixins/gl_paths_mixin';

export default {
  name: 'EnvironmentsEmptyState',
  mixins: [glPathsMixin()],
};
</script>
<template>
  <div class="empty-state">
    <div class="text-content">
      <h4 class="blank-state-title js-blank-state-title">
        {{ s__("Environments|You don't have any environments right now") }}
      </h4>
      <p class="blank-state-text">
        {{
          s__(`Environments|Environments are places where
        code gets deployed, such as staging or production.`)
        }}
        <a :href="glPaths.environmentsHelp"> {{ s__('Environments|More information') }} </a>
      </p>
    </div>
  </div>
</template>
