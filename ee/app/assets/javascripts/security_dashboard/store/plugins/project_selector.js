import projectSelectorModule from '../modules/project_selector';
import projectSearchModule from 'ee/vuex_shared/modules/project_search';

import * as projectSelectorMutationTypes from '../modules/project_selector/mutation_types';
import { BASE_FILTERS } from '../modules/filters/constants';

export default store => {
  store.registerModule('projectSelector', projectSelectorModule());
  store.registerModule(['projectSelector', 'search'], projectSearchModule());

  store.subscribe(({ type, payload }) => {
    if (type === `projectSelector/${projectSelectorMutationTypes.RECEIVE_PROJECTS_SUCCESS}`) {
      store.dispatch('filters/setFilterOptions', {
        filterId: 'project_id',
        options: [
          BASE_FILTERS.project_id,
          ...payload.map(({ name, id }) => ({
            name,
            id: id.toString(),
          })),
        ],
        lazy: true,
      });
    }
  });
};
