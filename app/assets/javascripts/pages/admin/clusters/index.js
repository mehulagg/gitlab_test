import initCreateCluster from '~/create_cluster/init_create_cluster';
import initClusterHealth from '../../projects/clusters/show/cluster_health';

document.addEventListener('DOMContentLoaded', () => {
  initCreateCluster(document, gon);
  initClusterHealth();
});
