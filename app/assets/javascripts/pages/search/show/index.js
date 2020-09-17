import Search from './search';
import initStateFilter from '~/search/state_filter';

document.addEventListener('DOMContentLoaded', () => {
  initStateFilter();
  if (gon.features.searchFilterByConfidential) {
    import('~/search/confidential_filter')
      .then(m => m.default())
      .catch(() => {});
  }
  return new Search();
});
