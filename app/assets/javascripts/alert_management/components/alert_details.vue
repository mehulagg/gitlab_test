<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import query from '../graphql/queries/details.query.graphql';

export default {
  i18n: {
    fullAlertDetailsTitle: s__('AlertManagement|Full Alert Details'),
    overviewTitle: s__('AlertManagement|Overview'),
  },
  components: {
    GlTab,
    GlTabs,
  },
  // props: {
  //   alertId: {
  //     type: String,
  //     required: true,
  //   },
  //   projectPath: {
  //     type: String,
  //     required: true,
  //   },
  // },
  apollo: {
    alert: {
      query,
      variables() {
        return {
          // fullPath: this.projectPath,
          fullPath: 'root/tr-dev-cluster-2',
          // alertId: `gid://gitlab/Gitlab::AlertManagement::Alert/${this.alertId}`,
          alertId: '1',
        };
      },
      update: data => {
        console.log(`data:`, data);
      },
      error: error => {
        console.error(`error:`, error);
      },
      result(res) {
        const alert = res.data.project?.alertManagementAlerts?.nodes[0];
        console.log(alert);
      },
    },
  },
  mounted() {
    this.$apollo.queries.alert.setOptions({
      fetchPolicy: 'cache-and-network',
    });
  },
};
</script>
<template>
  <div>
    <div class="d-flex justify-content-between">
      <gl-tabs>
        <gl-tab data-testid="overviewTab" :title="$options.i18n.overviewTitle">
          <ul class="pl-3">
            <li data-testid="startTimeItem" class="font-weight-bold mb-3 mt-2">
              {{ s__('AlertManagement|Start time:') }}
            </li>
            <li class="font-weight-bold my-3">
              {{ s__('AlertManagement|End time:') }}
            </li>
            <li class="font-weight-bold my-3">
              {{ s__('AlertManagement|Events:') }}
            </li>
          </ul>
        </gl-tab>
        <gl-tab data-testid="fullDetailsTab" :title="$options.i18n.fullAlertDetailsTitle" />
      </gl-tabs>
    </div>
  </div>
</template>
