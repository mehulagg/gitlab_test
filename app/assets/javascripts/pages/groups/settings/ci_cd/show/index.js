import initSettingsPanels from '~/settings_panels';
import initVariableList from '~/ci_variable_list';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize expandable settings panels
  initSettingsPanels();

  initVariableList();
});
