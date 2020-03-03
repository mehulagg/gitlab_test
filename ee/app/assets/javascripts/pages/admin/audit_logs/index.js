import AuditLogs from './audit_logs';
import Vue from 'vue';
import AuditLogFilter from './audit_log_filter.vue';

document.addEventListener('DOMContentLoaded', () => {
  new AuditLogs();

  const el = document.querySelector('#js-audit-log-app');

  new Vue({
    el,
    name: 'AuditLogApp',
    components: {
      AuditLogFilter,
    },
    render: createElement =>
      createElement(AuditLogFilter, {
        props: {
          ...el.dataset,
        },
      }),
  });
});
