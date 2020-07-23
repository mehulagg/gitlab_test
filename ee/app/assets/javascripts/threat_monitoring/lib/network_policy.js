import { safeDump } from 'js-yaml';

export default class NetworkPolicy {
  constructor() {
    this.name = '';
    this.description = '';
    this.isEnabled = false;
  }

  spec() {
    const spec = { podSelector: {} };

    if (!this.isEnabled) {
      spec.podSelector.matchSelector = {
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
      apiVersion: 'cilium.io/v2',
      kind: 'CiliumNetworkPolicy',
      metadata: {
        name: this.name,
      },
      spec: this.spec(),
    };

    if (this.description && this.description.length > 0) {
      policy.metadata.annotations = {
        'network-policy.gitlab.com/description': this.description,
      };
    }

    return safeDump(policy, { noArrayIndent: true });
  }
}
