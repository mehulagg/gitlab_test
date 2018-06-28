import initExpiresAtField from '~/access_tokens';
import multiProjectSelect from '~/project_select_multi';

document.addEventListener('DOMContentLoaded', () => {
  multiProjectSelect();
  initExpiresAtField();
});
