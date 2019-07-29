export const getCurrentStage = state =>
  state.stages.find(stage => stage.name === state.selectedStageName);
export const getDefaultStage = state => (state.stages.length ? state.stages[0] : null);
