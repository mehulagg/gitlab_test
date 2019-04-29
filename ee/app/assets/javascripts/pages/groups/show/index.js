import initSecurityDashboard from 'ee/security_dashboard/index';
import '~/pages/groups/show';

document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('#js-group-security-dashboard')) {
    initSecurityDashboard();
  }
});
