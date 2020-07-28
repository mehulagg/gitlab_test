import NetworkPolicyRule from './network_policy_rule';
import { RuleDirectionInbound } from './constants';

export default class NetworkPolicyRuleCIDR extends NetworkPolicyRule {
  constructor(params) {
    super(params);
    this.cidr = '';
  }

  get cidrList() {
    if (this.cidr.length === 0) return [];

    return this.cidr.split(/\s/);
  }

  spec() {
    if (this.cidrList.length === 0) return super.spec();

    return {
      [this.direction === RuleDirectionInbound ? 'fromCIDR' : 'toCIDR']: this.cidrList,
      ...super.spec(),
    };
  }
}
