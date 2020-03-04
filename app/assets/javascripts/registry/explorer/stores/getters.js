import { orderBy } from 'lodash';
// eslint-disable-next-line import/prefer-default-export
export const tags = state => {
  const { page, perPage } = state.tagsPagination;
  const filtered = state.tagsSearch
    ? state.tags.filter(t => t.name.includes(state.tagsSearch))
    : state.tags;
  const sorted = orderBy(filtered, [state.tagsSorting.field], [state.tagsSorting.order]);
  return sorted.slice((page - 1) * perPage, page * perPage);
};
