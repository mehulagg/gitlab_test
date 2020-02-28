<script>
import { mapState } from 'vuex';
import ProjectPolicyAlert from '../components/project_policy_alert.vue';

export default {
  components: {
    ProjectPolicyAlert,
  },
  computed: {
    ...mapState(['config']),
  },
};
</script>

<template>
  <div>
    <project-policy-alert v-if="!config.isGroupPage" />
    <transition name="slide">
      <router-view />
    </transition>
  </div>
</template>
