<script>
import { GlTabs, GlTab } from '@gitlab/ui';

export default {
  name: 'PolicyPreview',
  components: {
    GlTabs,
    GlTab,
  },
  props: {
    policyYaml: {
      type: String,
      required: true,
    },
    policyDescription: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-tabs data-testid="preview-tabs" content-class="gl-pt-0">
    <gl-tab :title="s__('NetworkPolicies|.yaml')">
      <pre class="gl-bg-white gl-rounded-top-left-none gl-rounded-top-right-none">{{
        policyYaml
      }}</pre>
    </gl-tab>
    <gl-tab :title="s__('NetworkPolicies|Rule')">
      <pre class="gl-bg-white gl-rounded-top-left-none gl-rounded-top-right-none">{{
        policyDescription
      }}</pre>
    </gl-tab>
  </gl-tabs>
</template>
