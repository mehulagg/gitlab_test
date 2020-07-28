import NetworkPolicyRule from './network_policy_rule';
import { RuleDirectionInbound } from './constants';

export default class NetworkPolicyRuleEndpoint extends NetworkPolicyRule {
  constructor(params) {
    super(params);
    this.matchLabels = '';
  }

  get matchSelector() {
    return this.matchLabels.split(/\s/).reduce((acc, item) => {
      const [key, value = ''] = item.split(':');
      if (key.length === 0) return acc;

      acc[key] = value.trim();
      return acc;
    }, {});
  }

  spec() {
    if (Object.keys(this.matchSelector).length === 0) return super.spec();

    return {
      [this.direction === RuleDirectionInbound ? 'fromEndpoints' : 'toEndpoints']: [
        {
          matchLabels: this.matchSelector,
        },
      ],
      ...super.spec(),
    };
  }
}
