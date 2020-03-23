import initU2F from './u2f';
import initWebauthn from './webauthn';

export default () => {
  if (gon.features?.webauthn) {
    initWebauthn();
  } else {
    initU2F();
  }
};
