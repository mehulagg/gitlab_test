import { deprecatedCreateFlash } from '~/flash';
import { __, sprintf } from '~/locale';
import { getParameterByName } from '~/lib/utils/common_utils';

const PARAMETER_NAME = 'leave';
const LEAVE_LINK_SELECTOR = '.js-leave-link';

export default function leaveByUrl(namespaceType) {
  if (!namespaceType) throw new Error('namespaceType not provided');

  const param = getParameterByName(PARAMETER_NAME);
  if (!param) return;

  const leaveLink = document.querySelector(LEAVE_LINK_SELECTOR);
  if (leaveLink) {
    leaveLink.click();
  } else {
    deprecatedCreateFlash(
      sprintf(__('You do not have permission to leave this %{namespaceType}.'), { namespaceType }),
    );
  }
}
