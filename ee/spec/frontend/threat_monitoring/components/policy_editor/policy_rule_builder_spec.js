import { mount } from '@vue/test-utils';
import PolicyRuleBuilder from 'ee/threat_monitoring/components/policy_editor/policy_rule_builder.vue';
import NetworkPolicy from 'ee/threat_monitoring/lib/network_policy';
import {
  RuleDirectionOutbound,
  EndpointMatchModeLabel,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
  PortMatchModePortProtocol,
} from 'ee/threat_monitoring/lib/constants';

describe('PolicyRuleBuilder component', () => {
  let wrapper;
  let policy;
  let rule;

  const factory = ({ propsData } = {}) => {
    wrapper = mount(PolicyRuleBuilder, {
      propsData: {
        policy,
        ruleIndex: 0,
        ...propsData,
      },
    });
  };

  beforeEach(() => {
    policy = new NetworkPolicy();
    policy.addRule();
    rule = policy.rules[0].rule;
    factory({});
  });

  const findEndpointLabels = () => wrapper.find("[data-testid='endpoint-labels']");
  const findRuleEndpoint = () => wrapper.find("[data-testid='rule-endpoint']");
  const findRuleEntity = () => wrapper.find("[data-testid='rule-entity']");
  const findRuleCIDR = () => wrapper.find("[data-testid='rule-cidr']");
  const findRuleFQDN = () => wrapper.find("[data-testid='rule-fqdn']");
  const findPorts = () => wrapper.find("[data-testid='ports']");

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders policy builder layout', () => {
    expect(wrapper.find('div').element).toMatchSnapshot();
  });

  it('updates rule direction upon selecting', () => {
    const el = wrapper.find("[id='direction']");
    el.findAll('option')
      .at(1)
      .setSelected();
    el.trigger('change');
    return el.vm.$nextTick().then(() => {
      expect(rule.direction).toEqual(RuleDirectionOutbound);
    });
  });

  it('updates endpoint match mode upon selecting', () => {
    const el = wrapper.find("[data-testid='endpoint-match-mode']");
    el.findAll('option')
      .at(1)
      .setSelected();
    el.trigger('change');
    return el.vm.$nextTick().then(() => {
      expect(policy.endpointMatchMode).toEqual(EndpointMatchModeLabel);
    });
  });

  it('does not render endpoint labels input', () => {
    expect(findEndpointLabels().exists()).toBe(false);
  });

  describe('when endpoint match mode is labels', () => {
    beforeEach(() => {
      policy = new NetworkPolicy();
      policy.endpointMatchMode = EndpointMatchModeLabel;
      policy.addRule();
      factory({});
    });

    it('renders endpoint labels input', () => {
      expect(findEndpointLabels().exists()).toBe(true);
    });

    it('updates endpoint labels', () => {
      const input = findEndpointLabels();
      input.setValue('foo:bar');
      return input.vm.$nextTick().then(() => {
        expect(policy.endpointLabels).toEqual('foo:bar');
      });
    });
  });

  it('updates rule type upon selecting', () => {
    const el = wrapper.find("[id='ruleMode']");
    el.findAll('option')
      .at(1)
      .setSelected();
    el.trigger('change');
    return el.vm.$nextTick().then(() => {
      expect(policy.rules[0].ruleType).toEqual(RuleTypeEntity);
    });
  });

  it('renders endpoint rule input', () => {
    expect(findRuleEndpoint().exists()).toBe(true);
  });

  it('does not render entity rule picker', () => {
    expect(findRuleEntity().exists()).toBe(false);
  });

  it('does not render cidr rule input', () => {
    expect(findRuleCIDR().exists()).toBe(false);
  });

  it('does not render fqdn rule input', () => {
    expect(findRuleFQDN().exists()).toBe(false);
  });

  describe('when policy type is entity', () => {
    beforeEach(() => {
      policy = new NetworkPolicy();
      policy.addRule();
      const container = policy.rules[0];
      container.ruleType = RuleTypeEntity;
      rule = container.rule;
      factory({});
    });

    it('does not render endpoint rule input', () => {
      expect(findRuleEndpoint().exists()).toBe(false);
    });

    it('renders entity rule picker', () => {
      expect(findRuleEntity().exists()).toBe(true);
    });

    it('does not render cidr rule input', () => {
      expect(findRuleCIDR().exists()).toBe(false);
    });

    it('does not render fqdn rule input', () => {
      expect(findRuleFQDN().exists()).toBe(false);
    });

    it('updates entity types', () => {
      const el = findRuleEntity();
      el.findAll('button')
        .at(2)
        .trigger('click');
      el.findAll('button')
        .at(3)
        .trigger('click');
      return el.vm.$nextTick().then(() => {
        expect(rule.entities).toEqual(['host', 'remote-node']);
      });
    });
  });

  describe('when policy type is cidr', () => {
    beforeEach(() => {
      policy = new NetworkPolicy();
      policy.addRule();
      const container = policy.rules[0];
      container.ruleType = RuleTypeCIDR;
      rule = container.rule;
      factory({});
    });

    it('renders endpoint rule input', () => {
      expect(findRuleEndpoint().exists()).toBe(false);
    });

    it('does not render entity rule picker', () => {
      expect(findRuleEntity().exists()).toBe(false);
    });

    it('renders cidr rule input', () => {
      expect(findRuleCIDR().exists()).toBe(true);
    });

    it('does not render fqdn rule input', () => {
      expect(findRuleFQDN().exists()).toBe(false);
    });

    it('updates cidr', () => {
      const el = findRuleCIDR();
      el.setValue('0.0.0.0/24');
      el.trigger('change');
      return el.vm.$nextTick().then(() => {
        expect(rule.cidr).toEqual('0.0.0.0/24');
      });
    });
  });

  describe('when policy type is fqdn', () => {
    beforeEach(() => {
      policy = new NetworkPolicy();
      policy.addRule();
      const container = policy.rules[0];
      container.ruleType = RuleTypeFQDN;
      rule = container.rule;
      factory({});
    });

    it('renders endpoint rule input', () => {
      expect(findRuleEndpoint().exists()).toBe(false);
    });

    it('does not render entity rule picker', () => {
      expect(findRuleEntity().exists()).toBe(false);
    });

    it('does not render cidr rule input', () => {
      expect(findRuleCIDR().exists()).toBe(false);
    });

    it('renders fqdn rule input', () => {
      expect(findRuleFQDN().exists()).toBe(true);
    });

    it('updates cidr', () => {
      const el = findRuleFQDN();
      el.setValue('some-service.com');
      el.trigger('change');
      return el.vm.$nextTick().then(() => {
        expect(rule.fqdn).toEqual('some-service.com');
      });
    });
  });

  it('updates port match mode upon selecting', () => {
    const el = wrapper.find("[id='portMatch']");
    el.findAll('option')
      .at(1)
      .setSelected();
    el.trigger('change');
    return el.vm.$nextTick().then(() => {
      expect(rule.portMatchMode).toEqual(PortMatchModePortProtocol);
    });
  });

  it('does not render ports input', () => {
    expect(findPorts().exists()).toBe(false);
  });

  describe('when port match mode is port/protocol', () => {
    beforeEach(() => {
      policy = new NetworkPolicy();
      policy.addRule();
      rule = policy.rules[0].rule;
      rule.portMatchMode = PortMatchModePortProtocol;
      factory({});
    });

    it('renders ports input', () => {
      expect(findPorts().exists()).toBe(true);
    });

    it('updates ports', () => {
      const input = findPorts();
      input.setValue('80/tcp');
      return input.vm.$nextTick().then(() => {
        expect(rule.ports).toEqual('80/tcp');
      });
    });
  });
});
