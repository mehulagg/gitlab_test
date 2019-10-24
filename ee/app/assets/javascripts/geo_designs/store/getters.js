// eslint-disable-next-line import/prefer-default-export
export const getDesignsByFilter = (state) => {
  const activeFilter = state.filterOptions[state.currentFilterIndex];
  if (activeFilter === 'all') {
    return state.designs
  }

  if (activeFilter === 'never') {
    return state.designs.filter(design => !design.sync_status);
  }

  return state.designs.filter(design => design.sync_status === activeFilter);
};