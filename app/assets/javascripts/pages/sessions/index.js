import initU2F from '../../shared/sessions/u2f';
import initWebauthn from '~/shared/sessions/webauthn';

if (gon.features && gon.features.webauthn) {
  document.addEventListener('DOMContentLoaded', initWebauthn);
} else {
  document.addEventListener('DOMContentLoaded', initU2F);
}
