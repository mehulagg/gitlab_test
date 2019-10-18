import initGroupSecurityDashboard from 'ee/security_dashboard/group_index';
import leaveByUrl from '~/namespaces/leave_by_url';
import initGroupDetails from '~/pages/groups/shared/group_details';

document.addEventListener('DOMContentLoaded', () => {
  leaveByUrl('group');

  if (document.querySelector('#js-group-security-dashboard')) {
    initGroupSecurityDashboard();
  } else {
    initGroupDetails();
  }
});
