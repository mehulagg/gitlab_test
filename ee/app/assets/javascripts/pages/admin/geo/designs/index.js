import initGeoDesigns from 'ee/geo_designs';
import PersistentUserCallout from '~/persistent_user_callout';

document.addEventListener('DOMContentLoaded', initGeoDesigns);
document.addEventListener('DOMContentLoaded', () => {
  const callout = document.querySelector('.user-callout');
  PersistentUserCallout.factory(callout);
});
