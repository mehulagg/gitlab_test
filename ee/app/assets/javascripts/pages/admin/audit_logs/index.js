import AuditLogs from './audit_logs';
import Vue from 'vue';
import AuditLogFilters from './audit_log_filters.vue';

document.addEventListener('DOMContentLoaded', () => {
  // new AuditLogs();

  const el = document.querySelector('#js-audit-log-app');

  new Vue({
    el,
    name: 'AuditLogApp',
    components: {
      AuditLogFilters,
    },
    render: createElement =>
      createElement(AuditLogFilters, {
        props: {
          ...el.dataset,
        },
      }),
  });
});
