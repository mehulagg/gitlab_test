import Search from './search';
import initStatusFilter from '~/search/status_filter';

document.addEventListener('DOMContentLoaded', () => {
  initStatusFilter();
  return new Search();
});
