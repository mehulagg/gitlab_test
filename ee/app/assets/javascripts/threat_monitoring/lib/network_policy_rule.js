import { PortMatchModeAny, RuleDirectionInbound } from './constants';

export default class NetworkPolicyRule {
  constructor(params = {}) {
    const { direction, portMatchMode, ports } = params;
    this.direction = direction || RuleDirectionInbound;
    this.portMatchMode = portMatchMode || PortMatchModeAny;
    this.ports = ports || '';
  }

  get portSelectors() {
    if (this.portMatchMode === PortMatchModeAny) return {};

    return this.ports.split(/\s/).reduce((acc, item) => {
      const [port, protocol = 'tcp'] = item.split('/');
      const portNumber = parseInt(port, 10);
      if (Number.isNaN(portNumber)) return acc;

      acc.push({ port, protocol: protocol.trim().toUpperCase() });
      return acc;
    }, []);
  }

  spec() {
    if (this.portMatchMode === PortMatchModeAny) return {};

    return { toPorts: [{ ports: this.portSelectors }] };
  }
}
