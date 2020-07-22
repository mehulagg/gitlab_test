<script>
import { GlLoadingIcon, GlAlert } from '@gitlab/ui';
import getIncident from '../graphql/queries/get_incident.query.graphql';
import { I18N } from '../constants';

export default {
  i18n: I18N,
  components: {
    GlLoadingIcon,
    GlAlert,
  },
  inject: ['projectPath', 'incidentId'],
  apollo: {
    incident: {
      query: getIncident,
      variables() {
        return {
          projectPath: this.projectPath,
          id: this.incidentId,
        };
      },
      update: ({ project: { issues: { nodes = [] } = {} } = {} }) => nodes[0],
      error() {
        this.errored = true;
      },
    },
  },
  data() {
    return {
      errored: false,
      isErrorAlertDismissed: false,
    };
  },
  computed: {
    loading() {
      return this.$apollo.queries.incident.loading;
    },
    showErrorMsg() {
      return this.errored && !this.isErrorAlertDismissed;
    },
    showIncident() {
      return this.incident && !this.errored;
    },
  },
};
</script>
<template>
  <div>
    <gl-alert v-if="showErrorMsg" variant="danger" @dismiss="isErrorAlertDismissed = true">
      {{ $options.i18n.errorMsg }}
    </gl-alert>
    <gl-loading-icon v-if="loading" size="lg" class="gl-mt-5" />
    <div
      v-if="showIncident"
      class="gl-display-flex gl-justify-content-space-between gl-align-items-center"
    >
      <h2 data-testid="incident-title">{{ incident.title }}</h2>
    </div>
  </div>
</template>
