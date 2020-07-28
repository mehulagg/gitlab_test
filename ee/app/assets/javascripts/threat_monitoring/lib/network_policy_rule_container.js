import { RuleTypeEntity, RuleTypeCIDR, RuleTypeFQDN } from './constants';
import NetworkPolicyRuleEndpoint from './network_policy_rule_endpoint';
import NetworkPolicyRuleEntity from './network_policy_rule_entity';
import NetworkPolicyRuleCIDR from './network_policy_rule_cidr';
import NetworkPolicyRuleFQDN from './network_policy_rule_fqdn';

export default class NetworkPolicyRuleContainer {
  constructor(ruleType) {
    this.buildRule(ruleType);
  }

  get ruleType() {
    return this.rule.constructor.name;
  }

  set ruleType(ruleType) {
    this.buildRule(ruleType);
  }

  buildRule(ruleType) {
    const direction = this.rule?.direction;
    const portMatchMode = this.rule?.portMatchMode;
    const ports = this.rule?.ports;
    const params = { direction, portMatchMode, ports };

    switch (ruleType) {
      case RuleTypeEntity:
        this.rule = new NetworkPolicyRuleEntity(params);
        break;
      case RuleTypeCIDR:
        this.rule = new NetworkPolicyRuleCIDR(params);
        break;
      case RuleTypeFQDN:
        this.rule = new NetworkPolicyRuleFQDN(params);
        break;
      default:
        this.rule = new NetworkPolicyRuleEndpoint(params);
    }
  }
}
