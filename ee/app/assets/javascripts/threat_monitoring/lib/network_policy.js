import { safeDump } from 'js-yaml';
import NetworkPolicyRuleContainer from './network_policy_rule_container';
import { EndpointMatchModeAny } from './constants';

export default class NetworkPolicy {
  constructor() {
    this.name = '';
    this.description = '';
    this.isEnabled = false;
    this.endpointMatchMode = EndpointMatchModeAny;
    this.endpointLabels = '';
    this.rules = [];

    this.apiVersion = 'cilium.io/v2';
    this.kind = 'CiliumNetworkPolicy';
  }

  get endpointSelector() {
    if (this.endpointMatchMode === EndpointMatchModeAny) return {};

    return this.endpointLabels.split(/\s/).reduce((acc, item) => {
      const [key, value = ''] = item.split(':');
      if (key.length === 0) return acc;

      acc[key] = value.trim();
      return acc;
    }, {});
  }

  addRule() {
    this.rules.push(new NetworkPolicyRuleContainer());
  }

  spec() {
    const spec = {};

    if (this.description && this.description.length > 0) {
      spec.description = this.description;
    }

    spec.endpointSelector =
      Object.keys(this.endpointSelector).length > 0 ? { matchLabels: this.endpointSelector } : {};
    this.rules.forEach(container => {
      const { direction } = container.rule;
      if (!spec[direction]) spec[direction] = [];

      spec[direction].push(container.rule.spec());
    });

    if (!this.isEnabled) {
      spec.endpointSelector.matchLabels = {
        ...spec.endpointSelector.matchLabels,
        'network-policy.gitlab.com/disabled_by': 'gitlab',
      };
    }

    return spec;
  }

  humanize() {
    return this.name;
  }

  toYaml() {
    const policy = {
      apiVersion: this.apiVersion,
      kind: this.kind,
      metadata: {
        name: this.name,
      },
      spec: this.spec(),
    };

    return safeDump(policy, { noArrayIndent: true });
  }
}
