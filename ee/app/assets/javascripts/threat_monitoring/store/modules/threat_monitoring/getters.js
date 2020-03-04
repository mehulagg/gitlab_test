import { INVALID_CURRENT_ENVIRONMENT_NAME } from '../../../constants';

export const currentEnvironmentName = ({ currentEnvironmentId, environments }) => {
  const environment = environments.find(({ id }) => id === currentEnvironmentId);
  return environment ? environment.name : INVALID_CURRENT_ENVIRONMENT_NAME;
};

export const hasHistory = ({ wafStatistics }) =>
  Boolean(wafStatistics.history.nominal.length || wafStatistics.history.anomalous.length);
