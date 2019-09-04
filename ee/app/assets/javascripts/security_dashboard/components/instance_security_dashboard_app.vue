<script>
import { mapGetters } from 'vuex';
import { GlButton, GlEmptyState, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';
import SecurityDashboard from './app.vue';

export default {
  name: 'InstanceSecurityDashboard',
  components: {
    GlButton,
    GlEmptyState,
    GlLink,
    SecurityDashboard,
  },
  props: {
    dashboardDocumentation: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    emptyDashboardStateSvgPath: {
      type: String,
      required: true,
    },
    projectsEndpoint: {
      type: String,
      required: true,
    },
    vulnerabilitiesEndpoint: {
      type: String,
      required: true,
    },
    vulnerabilitiesCountEndpoint: {
      type: String,
      required: true,
    },
    vulnerabilitiesHistoryEndpoint: {
      type: String,
      required: true,
    },
    vulnerabilityFeedbackHelpPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showProjectSelector: false,
    };
  },
  methods: {
    toggleProjectSelector() {
      this.showProjectSelector = !this.showProjectSelector;
    },
  },
  computed: {
    toggleButtonProps() {
      return this.showProjectSelector
        ? {
            variant: 'success',
            text: s__('SecurityDashboard|Return to dashboard'),
          }
        : {
            variant: 'secondary',
            text: s__('SecurityDashboard|Edit dashboard'),
          };
    },
    ...mapGetters('projects', ['hasProjects']),
    shouldShowEmptyState() {
      return this.hasProjects;
    },
  },
};
</script>

<template>
  <article>
    <header class="page-title-holder flex-fill d-flex align-items-center">
      <h2 class="page-title">{{ s__('SecurityDashboard|Security Dashboard') }}</h2>
      <gl-button
        new-style
        class="page-title-controls"
        @click="toggleProjectSelector"
        :variant="toggleButtonProps.variant"
        >{{ toggleButtonProps.text }}</gl-button
      >
    </header>

    <!-- Consider v-show for smoother transition and preserving state -->
    <section v-if="showProjectSelector" class="js-dashboard-project-selector">
      <h3>{{ s__('SecurityDashboard|Add or remove projects from your dashboard') }}</h3>
    </section>

    <template v-else>
      <gl-empty-state
        v-if="shouldShowEmptyState"
        :title="s__('SecurityDashboard|Add a project to your dashboard')"
        :svg-path="emptyStateSvgPath"
      >
        <template v-slot:description>
          {{
            s__(
              'SecurityDashboard|The security dashboard displays the latest security findings for projects you wish to monitor. Select "Edit dashboard" to add and remove projects.',
            )
          }}
          <gl-link :href="dashboardDocumentation">More information</gl-link>.
        </template>
        <template v-slot:actions>
          <gl-button new-style variant="success" @click="toggleProjectSelector">
            {{ s__('SecurityDashboard|Add projects') }}
          </gl-button>
        </template>
      </gl-empty-state>

      <security-dashboard
        v-else
        class="js-security-dashboard"
        :dashboard-documentation="dashboardDocumentation"
        :empty-state-svg-path="emptyDashboardStateSvgPath"
        :projects-endpoint="projectsEndpoint"
        :vulnerabilities-endpoint="vulnerabilitiesEndpoint"
        :vulnerabilities-count-endpoint="vulnerabilitiesCountEndpoint"
        :vulnerabilities-history-endpoint="vulnerabilitiesHistoryEndpoint"
        :vulnerability-feedback-help-path="vulnerabilityFeedbackHelpPath"
      />
    </template>
  </article>
</template>
