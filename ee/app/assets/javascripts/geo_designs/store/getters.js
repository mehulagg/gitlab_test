// eslint-disable-next-line import/prefer-default-export
export const getDesignsByFilter = state => {
  const activeFilter = state.filterOptions[state.currentFilterIndex];
  let designsByStatus = [];

  if (activeFilter === 'all') {
    designsByStatus = state.designs;
  } else if (activeFilter === 'never') {
    designsByStatus = state.designs.filter(design => !design.sync_status);
  } else {
    designsByStatus = state.designs.filter(design => design.sync_status === activeFilter);
  }

  return designsByStatus.filter(design => design.name.includes(state.searchFilter));
};
