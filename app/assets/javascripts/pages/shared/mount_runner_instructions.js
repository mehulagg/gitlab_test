import Vue from 'vue';
import InstallRunnerInstructions from '~/vue_shared/components/runner_instructions.vue';

export function initInstallRunner() {
  const installRunnerEl = document.getElementById('js-install-runner');

  if (installRunnerEl) {
    // eslint-disable-next-line no-new
    new Vue({
      el: installRunnerEl,
      provide: {
        instructionsPath: '/path',
      },
      render(createElement) {
        return createElement(InstallRunnerInstructions);
      },
    });
  }
}
