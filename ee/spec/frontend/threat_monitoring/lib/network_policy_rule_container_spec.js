import NetworkPolicyRuleContainer from 'ee/threat_monitoring/lib/network_policy_rule_container';
import {
  RuleTypeEndpoint,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
  RuleDirectionOutbound,
  PortMatchModePortProtocol,
} from 'ee/threat_monitoring/lib/constants';

describe('NetworkPolicyRuleContainer', () => {
  let container;

  beforeEach(() => {
    container = new NetworkPolicyRuleContainer();
  });

  it('returns default ruleType', () => {
    expect(container.ruleType).toEqual(RuleTypeEndpoint);
  });

  describe.each`
    ruleType            | instanceClass
    ${RuleTypeEndpoint} | ${'NetworkPolicyRuleEndpoint'}
    ${RuleTypeEntity}   | ${'NetworkPolicyRuleEntity'}
    ${RuleTypeCIDR}     | ${'NetworkPolicyRuleCIDR'}
    ${RuleTypeFQDN}     | ${'NetworkPolicyRuleFQDN'}
  `('buildRule $ruleType', ({ ruleType, instanceClass }) => {
    beforeEach(() => {
      container.rule.direction = RuleDirectionOutbound;
      container.rule.portMatchMode = PortMatchModePortProtocol;
      container.rule.ports = '80/tcp';
      container.buildRule(ruleType);
    });

    it('builds correct instance', () => {
      expect(container.ruleType).toBe(instanceClass);
      expect(container.rule.direction).toEqual(RuleDirectionOutbound);
      expect(container.rule.portMatchMode).toEqual(PortMatchModePortProtocol);
      expect(container.rule.ports).toEqual('80/tcp');
    });
  });
});
