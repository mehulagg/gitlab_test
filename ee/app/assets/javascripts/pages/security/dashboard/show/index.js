import initInstanceSecurityDashboard from 'ee/security_dashboard/instance_index';

if (gon.features?.instanceSecurityDashboard) {
  document.addEventListener('DOMContentLoaded', initInstanceSecurityDashboard);
}
