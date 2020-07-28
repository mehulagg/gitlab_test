import NetworkPolicyRuleEndpoint from 'ee/threat_monitoring/lib/network_policy_rule_endpoint';
import NetworkPolicyRuleEntity from 'ee/threat_monitoring/lib/network_policy_rule_entity';
import NetworkPolicyRuleCIDR from 'ee/threat_monitoring/lib/network_policy_rule_cidr';
import NetworkPolicyRuleFQDN from 'ee/threat_monitoring/lib/network_policy_rule_fqdn';
import {
  RuleDirectionOutbound,
  PortMatchModePortProtocol,
  EntityTypes,
} from 'ee/threat_monitoring/lib/constants';

let rule;

function testPortMatchers() {
  describe('given rule has port matchers', () => {
    beforeEach(() => {
      rule.portMatchMode = PortMatchModePortProtocol;
      rule.ports = '80 81/tcp 82/udp invalid';
    });

    it('includes correct toPorts block', () => {
      expect(rule.spec()).toEqual(
        expect.objectContaining({
          toPorts: [
            {
              ports: [
                { port: '80', protocol: 'TCP' },
                { port: '81', protocol: 'TCP' },
                { port: '82', protocol: 'UDP' },
              ],
            },
          ],
        }),
      );
    });
  });
}

describe('NetworkPolicyRuleEndpoint', () => {
  beforeEach(() => {
    rule = new NetworkPolicyRuleEndpoint();
  });

  it('returns empty spec', () => {
    expect(rule.spec()).toEqual({});
  });

  testPortMatchers();

  describe('with match labels', () => {
    beforeEach(() => {
      rule.matchLabels = 'one two:val three: two:overwrite four: five';
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({
        fromEndpoints: [
          {
            matchLabels: {
              one: '',
              two: 'overwrite',
              three: '',
              five: '',
              four: '',
            },
          },
        ],
      });
    });

    testPortMatchers();
  });

  describe('with outbound direction', () => {
    beforeEach(() => {
      rule.direction = RuleDirectionOutbound;
      rule.matchLabels = 'foo:bar';
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({
        toEndpoints: [{ matchLabels: { foo: 'bar' } }],
      });
    });

    testPortMatchers();
  });
});

describe('NetworkPolicyRuleEntity', () => {
  beforeEach(() => {
    rule = new NetworkPolicyRuleEntity();
  });

  it('returns empty spec', () => {
    expect(rule.spec()).toEqual({});
  });

  testPortMatchers();

  describe('with entities', () => {
    beforeEach(() => {
      rule.entities = [EntityTypes.HOST, EntityTypes.WORLD];
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({
        fromEntities: [EntityTypes.HOST, EntityTypes.WORLD],
      });
    });

    testPortMatchers();
  });

  describe('with entities contain ALL', () => {
    beforeEach(() => {
      rule.entities = [EntityTypes.HOST, EntityTypes.WORLD, EntityTypes.ALL];
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({ fromEntities: [EntityTypes.ALL] });
    });
  });

  describe('with entities contain all entities', () => {
    beforeEach(() => {
      rule.entities = Object.keys(EntityTypes)
        .map(type => EntityTypes[type])
        .filter(entity => entity !== EntityTypes.ALL);
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({ fromEntities: [EntityTypes.ALL] });
    });
  });

  describe('with outbound direction', () => {
    beforeEach(() => {
      rule.direction = RuleDirectionOutbound;
      rule.entities = [EntityTypes.HOST];
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({
        toEntities: [EntityTypes.HOST],
      });
    });

    testPortMatchers();
  });
});

describe('NetworkPolicyRuleCIDR', () => {
  beforeEach(() => {
    rule = new NetworkPolicyRuleCIDR();
  });

  it('returns empty spec', () => {
    expect(rule.spec()).toEqual({});
  });

  testPortMatchers();

  describe('with cidr masks', () => {
    beforeEach(() => {
      rule.cidr = '0.0.0.0/24 1.1.1.1/32';
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({ fromCIDR: ['0.0.0.0/24', '1.1.1.1/32'] });
    });

    testPortMatchers();
  });

  describe('with outbound direction', () => {
    beforeEach(() => {
      rule.direction = RuleDirectionOutbound;
      rule.cidr = '0.0.0.0/24';
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({ toCIDR: ['0.0.0.0/24'] });
    });

    testPortMatchers();
  });
});

describe('NetworkPolicyRuleFQDN', () => {
  beforeEach(() => {
    rule = new NetworkPolicyRuleFQDN();
  });

  it('returns empty spec', () => {
    expect(rule.spec()).toEqual({});
  });

  testPortMatchers();

  describe('with fqdn', () => {
    beforeEach(() => {
      rule.fqdn = 'some-service.com another-service.com';
    });

    it('returns empty spec', () => {
      expect(rule.spec()).toEqual({});
    });

    testPortMatchers();
  });

  describe('with outbound direction', () => {
    beforeEach(() => {
      rule.direction = RuleDirectionOutbound;
      rule.fqdn = 'some-service.com another-service.com';
    });

    it('returns correct spec', () => {
      expect(rule.spec()).toEqual({
        toFQDNs: [{ matchName: 'some-service.com' }, { matchName: 'another-service.com' }],
      });
    });

    testPortMatchers();
  });
});
