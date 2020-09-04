import { parseBoolean } from '../../../lib/utils/common_utils';

export default (initialState = {}) => ({
  allowUserDefinedNamespace: parseBoolean(initialState.allowUserDefinedNamespace),
  clusterConnectHelpPath: initialState.clusterConnectHelpPath,
  managedClustersHelpLink: initialState.managedClustersHelpLink,
  rbacHelpLink: initialState.rbacHelpLink
});
