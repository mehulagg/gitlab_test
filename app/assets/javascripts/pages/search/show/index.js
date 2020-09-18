import Search from './search';
import initStateFilter from '~/search/state_filter';

document.addEventListener('DOMContentLoaded', () => {
  if (gon.features.jsGlobalSearch) {
    return import('~/search')
      .then(m => m.default())
      .catch(() => {});
  }

  initStateFilter();
  return new Search();
});
