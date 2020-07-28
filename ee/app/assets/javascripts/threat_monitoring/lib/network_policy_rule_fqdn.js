import NetworkPolicyRule from './network_policy_rule';
import { RuleDirectionInbound } from './constants';

export default class NetworkPolicyRuleFQDN extends NetworkPolicyRule {
  constructor(params) {
    super(params);
    this.fqdn = '';
  }

  get fqdnList() {
    if (this.fqdn.length === 0) return [];

    return this.fqdn.split(/\s/);
  }

  spec() {
    if (this.direction === RuleDirectionInbound) return super.spec();
    if (this.fqdnList.length === 0) return super.spec();

    return {
      toFQDNs: this.fqdnList.map(fqdn => ({ matchName: fqdn })),
      ...super.spec(),
    };
  }
}
