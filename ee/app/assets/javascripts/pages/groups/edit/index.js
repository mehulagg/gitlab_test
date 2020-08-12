import '~/pages/groups/edit';
import initAccessRestrictionField from 'ee/groups/settings/access_restriction_field';
import { __ } from '~/locale';

document.addEventListener('DOMContentLoaded', () => {
  initAccessRestrictionField('.js-allowed-email-domains', {
    placeholder: __('Enter domain'),
    errorMessage: __('The domain you entered is misformatted.'),
    disallowedValueErrorMessage: __('The domain you entered is not allowed.'),
  });
  initAccessRestrictionField(
    '.js-ip-restriction',
    { placeholder: __('Enter IP address range') },
    'ip_restriction_field',
  );
});
