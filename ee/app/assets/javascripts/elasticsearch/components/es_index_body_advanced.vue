<script>
import { __ } from '~/locale';
import { GlButton } from '@gitlab/ui';
import SectionRevealButton from '~/vue_shared/components/section_reveal_button.vue';

export default {
  components: {
    SectionRevealButton,
    GlButton,
  },
  props: {
    index: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showSectionItems: false,
      keyShown: false,
    };
  },
  computed: {
    hiddenKey() {
      if (this.keyShown) {
        return this.index.aws_secret_access_key;
      }
      const len = this.index.aws_secret_access_key.length;
      return Array(len + 1).join('*');
    },
    secretKeyToggleText() {
      return this.keyShown ? __('Hide') : __('Show');
    },
  },
  methods: {
    handleSectionToggle(toggleState) {
      this.showSectionItems = toggleState;
    },
    toggleShowKey() {
      this.keyShown = !this.keyShown;
    },
  },
};
</script>
<template>
  <div>
    <section-reveal-button
      :button-title="s__('Elasticsearch|Advanced configuration')"
      @toggleButton="handleSectionToggle"
    />
    <div
      v-show="showSectionItems"
      class="col-md-6 prepend-left-15 prepend-top-10 section-items-container"
    >
      <dl class="mb-0">
        <template v-if="index.aws">
          <dt class="font-weight-normal text-secondary">{{ s__('Elasticsearch|AWS region') }}:</dt>
          <dd class="font-weight-bold">{{ index.aws_region }}</dd>

          <dt class="font-weight-normal text-secondary">{{ s__('Elasticsearch|AWS Access Key ID') }}:</dt>
          <dd class="font-weight-bold">{{ index.aws_access_key }}</dd>

          <dt class="font-weight-normal text-secondary">{{ s__('Elasticsearch|AWS Secret Access Key') }}:</dt>
          <dd class="font-weight-bold d-flex align-items-center">
            <span class="text-monospace">{{ hiddenKey }}</span>
            <gl-button
              class="btn btn-link ml-1"
              :title="secretKeyToggleText"
              @click="toggleShowKey"
            >
              {{ secretKeyToggleText }}
            </gl-button>
          </dd>
        </template>

        <!--        <dt class="font-weight-normal text-secondary">{{ s__('Elasticsearch|GitLab schema version:') }}</dt>-->
        <!--        <dd class="font-weight-bold">{{ index.version }}</dd>-->

        <dt class="font-weight-normal text-secondary">
          {{ s__('Elasticsearch|Number of shards') }}:
        </dt>
        <dd class="font-weight-bold">{{ index.shards }}</dd>

        <dt class="font-weight-normal text-secondary">
          {{ s__('Elasticsearch|Number of replicas') }}:
        </dt>
        <dd class="font-weight-bold">{{ index.replicas }}</dd>
      </dl>
    </div>
  </div>
</template>
