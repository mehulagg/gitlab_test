<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { GlButton, GlEmptyState, GlLink, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import SecurityDashboard from './app.vue';

export default {
  name: 'InstanceSecurityDashboard',
  components: {
    GlButton,
    GlEmptyState,
    GlLink,
    GlLoadingIcon,
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
    ...mapActions('projects', ['setProjectsEndpoint', 'fetchProjects']),
    toggleProjectSelector() {
      this.showProjectSelector = !this.showProjectSelector;
    },
  },
  created() {
    this.setProjectsEndpoint(this.projectsEndpoint);
    this.fetchProjects();
  },
  computed: {
    ...mapState('projects', ['isInitialized', 'projects']),
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
    shouldShowEmptyState() {
      return this.isInitialized && this.projects.length === 0;
    },
  },
};
</script>

<template>
  <article>
    <header class="page-title-holder flex-fill d-flex align-items-center">
      <h2 class="page-title">{{ s__('SecurityDashboard|Security Dashboard') }}</h2>
      <gl-button
        v-if="isInitialized"
        new-style
        class="page-title-controls js-project-selector-toggle"
        @click="toggleProjectSelector"
        :variant="toggleButtonProps.variant"
        v-text="toggleButtonProps.text"
      />
    </header>

    <template v-if="isInitialized">
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
          :dashboard-documentation="dashboardDocumentation"
          :empty-state-svg-path="emptyDashboardStateSvgPath"
          :projects-endpoint="projectsEndpoint"
          :vulnerabilities-endpoint="vulnerabilitiesEndpoint"
          :vulnerabilities-count-endpoint="vulnerabilitiesCountEndpoint"
          :vulnerabilities-history-endpoint="vulnerabilitiesHistoryEndpoint"
          :vulnerability-feedback-help-path="vulnerabilityFeedbackHelpPath"
        />
      </template>
    </template>

    <gl-loading-icon v-else size="md" />
  </article>
</template>
