import initSettingsPanels from '~/settings_panels';
import SecretValues from '~/behaviors/secret_values';
import registrySettingsApp from '~/registry/settings/registry_settings_bundle';
import initVariableList from '~/ci_variable_list';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize expandable settings panels
  initSettingsPanels();

  const runnerToken = document.querySelector('.js-secret-runner-token');
  if (runnerToken) {
    const runnerTokenSecretValue = new SecretValues({
      container: runnerToken,
    });
    runnerTokenSecretValue.init();
  }

  registrySettingsApp();

  initVariableList();
});
