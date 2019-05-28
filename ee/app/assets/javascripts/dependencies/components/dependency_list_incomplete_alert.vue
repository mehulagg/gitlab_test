<script>
export default {
  name: 'DependencyListIncompeteAlert',
  components: {
    GlButton,
    Icon,
  },
  props: {
    jobPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      closed: false,
    };
  },
  methods: {
    close() {
      this.closed = true;
    },
  },
};
</script>

<template>
  <div v-if="!closed" class="warning_message">
    <h4>{{ __('Unsupported file(s) detected') }}</h4>
    <p>
      {{
        __(
          'One or more of your dependency files are not supported, and the dependency list may be incomplete. Below is a list of supported file types.',
        )
      }}
    </p>
    <ul>
      <li>package-lock.json</li>
      <li>composer.lock</li>
      <li>Gemfile.lock</li>
      <li>gems.locked</li>
      <li>yarn.lock</li>
      <li>requirements.txt</li>
      <li>pom.xml</li>
    </ul>
  </div>
</template>
