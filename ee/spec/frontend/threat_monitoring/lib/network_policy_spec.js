import NetworkPolicy from 'ee/threat_monitoring/lib/network_policy';
import { EndpointMatchModeAny, EndpointMatchModeLabel } from 'ee/threat_monitoring/lib/constants';

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

  it('updates endpoint match mode', () => {
    expect(policy.endpointMatchMode).toEqual(EndpointMatchModeAny);
    policy.endpointMatchMode = EndpointMatchModeLabel;
    expect(policy.endpointMatchMode).toEqual(EndpointMatchModeLabel);
  });

  it('updates endpoint labels', () => {
    expect(policy.endpointLabels).toEqual('');
    policy.endpointLabels = 'foo:bar';
    expect(policy.endpointLabels).toEqual('foo:bar');
  });

  it('adds a new rule', () => {
    policy.addRule();
    expect(policy.rules.length).toEqual(1);
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
  endpointSelector:
    matchLabels:
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
spec:
  description: test description
  endpointSelector:
    matchLabels:
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
  endpointSelector: {}
`);
      });
    });

    describe('when endpoint labels are not empty', () => {
      beforeEach(() => {
        policy.endpointMatchMode = EndpointMatchModeLabel;
        policy.endpointLabels = 'one two:val three: two:overwrite four: five';
      });

      it('returns yaml representation', () => {
        expect(policy.toYaml()).toEqual(`apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: test-policy
spec:
  endpointSelector:
    matchLabels:
      one: ''
      two: overwrite
      three: ''
      four: ''
      five: ''
      network-policy.gitlab.com/disabled_by: gitlab
`);
      });
    });

    describe('with a rule', () => {
      beforeEach(() => {
        policy.addRule();
        const container = policy.rules[0];
        container.rule.matchLabels = 'foo:bar';
      });

      it('returns yaml representation', () => {
        expect(policy.toYaml()).toEqual(`apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: test-policy
spec:
  endpointSelector:
    matchLabels:
      network-policy.gitlab.com/disabled_by: gitlab
  ingress:
  - fromEndpoints:
    - matchLabels:
        foo: bar
`);
      });
    });
  });
});
