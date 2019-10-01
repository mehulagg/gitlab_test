import { KUBERNETES_VERSIONS } from '../constants';

export default () => ({
  isValidatingCredentials: false,
  validCredentials: false,

  clusterName: '',
  environmentScope: '*',
  kubernetesVersion: KUBERNETES_VERSIONS[0].value,
  selectedRegion: '',
  selectedRole: '',
  selectedKeyPair: '',
  selectedVpc: '',
  selectedSubnet: '',
  selectedSecurityGroup: '',

  gitlabManagedCluster: true,
});
