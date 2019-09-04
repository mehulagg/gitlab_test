import Vue from 'vue';
import createStore from 'ee/security_dashboard/store';
import router from 'ee/security_dashboard/store/router';
import InstanceSecurityDashboardApp from 'ee/security_dashboard/components/instance_security_dashboard_app.vue';

if (gon.features && gon.features.securityDashboard) {
  document.addEventListener('DOMContentLoaded', () => {
    const el = document.querySelector('#js-security');
    const {
      dashboardDocumentation,
      emptyStateSvgPath,
      emptyDashboardStateSvgPath,
      projectsEndpoint,
      vulnerabilitiesCountEndpoint,
      vulnerabilitiesEndpoint,
      vulnerabilitiesHistoryEndpoint,
      vulnerabilityFeedbackHelpPath,
    } = el.dataset;
    const store = createStore();

    return new Vue({
      el,
      store,
      router,
      components: {
        InstanceSecurityDashboardApp,
      },
      render(createElement) {
        return createElement(InstanceSecurityDashboardApp, {
          props: {
            dashboardDocumentation,
            emptyStateSvgPath,
            emptyDashboardStateSvgPath,
            projectsEndpoint,
            vulnerabilitiesCountEndpoint,
            vulnerabilitiesEndpoint,
            vulnerabilitiesHistoryEndpoint,
            vulnerabilityFeedbackHelpPath,
          },
        });
      },
    });
  });
}
