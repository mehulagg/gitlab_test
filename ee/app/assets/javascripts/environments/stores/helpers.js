/**
 * Deploy boards are EE only.
 *
 * @param {Object} environment
 * @returns {Object}
 */
export const setDeployBoard = (oldEnvironmentState, environment) => {
  let parsedEnvironment = environment;
  if (environment.size === 1 && environment.rollout_status) {
    parsedEnvironment = {
      ...environment,
      hasDeployBoard: true,
      isDeployBoardVisible:
        oldEnvironmentState.isDeployBoardVisible === false
          ? oldEnvironmentState.isDeployBoardVisible
          : true,
      deployBoardData:
        environment.rollout_status.status === 'found' ? environment.rollout_status : {},
      isLoadingDeployBoard: environment.rollout_status.status === 'loading',
      isEmptyDeployBoard: environment.rollout_status.status === 'not_found',
      hasLegacyAppLabel: environment.rollout_status.has_legacy_app_label,
    };
  }
  return parsedEnvironment;
};
