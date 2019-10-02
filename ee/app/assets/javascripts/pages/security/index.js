import Vue from 'vue';
import createStore from 'ee/security_dashboard/store';
import router from 'ee/security_dashboard/store/router';
import DashboardComponent from 'ee/security_dashboard/components/instance_security_dashboard.vue';

// if (gon.features && gon.features.securityDashboard) {
document.addEventListener(
  'DOMContentLoaded',
  () =>
    new Vue({
      el: '#js-security',
      store: createStore(),
      router,
      components: {
        DashboardComponent,
      },
      render(createElement) {
        return createElement(DashboardComponent, {
          props: {
            emptyDashboardStateSvgPath: '',
            projectsEndpoint: '',
            vulnerabilitiesCountEndpoint: '',
            vulnerabilityFeedbackHelpPath: '',
            dashboardDocumentation: '',
            emptyStateSvgPath: '',
            vulnerabilitiesEndpoint: '',
            vulnerabilitiesHistoryEndpoint: '',
          },
        });
      },
    }),
);
// }
