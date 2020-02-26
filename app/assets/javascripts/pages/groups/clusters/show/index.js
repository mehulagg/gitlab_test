import ClustersBundle from '~/clusters/clusters_bundle';
import initClusterHealth from '../../../projects/clusters/show/cluster_health';

document.addEventListener('DOMContentLoaded', () => {
  new ClustersBundle(); // eslint-disable-line no-new
  initClusterHealth();
});
