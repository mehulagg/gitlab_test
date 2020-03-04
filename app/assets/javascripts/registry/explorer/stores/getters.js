import { orderBy } from 'lodash';

export const filteredTags = state => {
  return state.tagsSearch ? state.tags.filter(t => t.name.includes(state.tagsSearch)) : state.tags;
};

export const tags = (state, getters) => {
  const { page, perPage } = state.tagsPagination;
  const sorted = orderBy(
    getters.filteredTags,
    [state.tagsSorting.field],
    [state.tagsSorting.order],
  );
  return sorted.slice((page - 1) * perPage, page * perPage);
};
