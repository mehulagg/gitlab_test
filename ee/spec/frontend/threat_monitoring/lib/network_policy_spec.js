import NetworkPolicy from 'ee/threat_monitoring/lib/network_policy';

describe('NetworkPolicy', () => {
  let policy;

  beforeEach(() => {
    policy = new NetworkPolicy();
  });

  it('returns correct apiVersion', () => {
    expect(policy.apiVersion).toEqual('cilium.io/v2');
  });

  it('returns correct kind', () => {
    expect(policy.kind).toEqual('CiliumNetworkPolicy');
  });

  it('updates policy name', () => {
    expect(policy.name).toEqual('');
    policy.name = 'test';
    expect(policy.name).toEqual('test');
  });

  it('updates policy description', () => {
    expect(policy.description).toEqual('');
    policy.description = 'test';
    expect(policy.description).toEqual('test');
  });

  it('updates enforcement state', () => {
    expect(policy.isEnabled).toBe(false);
    policy.isEnabled = true;
    expect(policy.isEnabled).toBe(true);
  });

  describe('toYaml', () => {
    beforeEach(() => {
      policy.name = 'test-policy';
    });

    it('returns yaml representation', () => {
      expect(policy.toYaml()).toEqual(`apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: test-policy
spec:
  podSelector:
    matchSelector:
      network-policy.gitlab.com/disabled_by: gitlab
`);
    });

    describe('when description is not empty', () => {
      beforeEach(() => {
        policy.description = 'test description';
      });

      it('returns yaml representation', () => {
        expect(policy.toYaml()).toEqual(`apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: test-policy
  annotations:
    network-policy.gitlab.com/description: test description
spec:
  podSelector:
    matchSelector:
      network-policy.gitlab.com/disabled_by: gitlab
`);
      });
    });

    describe('when policy is enabled', () => {
      beforeEach(() => {
        policy.isEnabled = true;
      });

      it('returns yaml representation', () => {
        expect(policy.toYaml()).toEqual(`apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: test-policy
spec:
  podSelector: {}
`);
      });
    });
  });
});
