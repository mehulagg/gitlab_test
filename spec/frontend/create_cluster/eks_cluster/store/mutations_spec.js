import {
  SET_CLUSTER_NAME,
  SET_ENVIRONMENT_SCOPE,
  SET_KUBERNETES_VERSION,
  SET_REGION,
  SET_VPC,
  SET_KEY_PAIR,
  SET_SUBNET,
  SET_ROLE,
} from '~/create_cluster/eks_cluster/store/mutation_types';
import createState from '~/create_cluster/eks_cluster/store/state';
import mutations from '~/create_cluster/eks_cluster/store/mutations';

describe('Create EKS cluster store mutations', () => {
  let clusterName;
  let environmentScope;
  let kubernetesVersion;
  let state;
  let region;
  let vpc;
  let subnet;
  let role;
  let keyPair;

  beforeEach(() => {
    clusterName = 'my cluster';
    environmentScope = 'production';
    kubernetesVersion = '11.1';
    region = { name: 'regions-1' };
    vpc = { name: 'vpc-1' };
    subnet = { name: 'subnet-1' };
    role = { name: 'role-1' };
    keyPair = { name: 'key pair' };

    state = createState();
  });

  it.each`
    mutation                  | mutatedProperty        | payload                  | expectedValue        | expectedValueDescription
    ${SET_CLUSTER_NAME}       | ${'clusterName'}       | ${{ clusterName }}       | ${clusterName}       | ${'cluster name'}
    ${SET_ENVIRONMENT_SCOPE}  | ${'environmentScope'}  | ${{ environmentScope }}  | ${environmentScope}  | ${'environment scope'}
    ${SET_KUBERNETES_VERSION} | ${'kubernetesVersion'} | ${{ kubernetesVersion }} | ${kubernetesVersion} | ${'kubernetes version'}
    ${SET_ROLE}               | ${'selectedRole'}      | ${{ role }}              | ${role}              | ${'selected role payload'}
    ${SET_REGION}             | ${'selectedRegion'}    | ${{ region }}            | ${region}            | ${'selected region payload'}
    ${SET_KEY_PAIR}           | ${'selectedKeyPair'}   | ${{ keyPair }}           | ${keyPair}           | ${'selected key pair payload'}
    ${SET_VPC}                | ${'selectedVpc'}       | ${{ vpc }}               | ${vpc}               | ${'selected vpc payload'}
    ${SET_SUBNET}             | ${'selectedSubnet'}    | ${{ subnet }}            | ${subnet}            | ${'selected sybnet payload'}
  `(`$mutation sets $mutatedProperty to $expectedValueDescription`, data => {
    const { mutation, mutatedProperty, payload, expectedValue } = data;

    mutations[mutation](state, payload);
    expect(state[mutatedProperty]).toBe(expectedValue);
  });
});
