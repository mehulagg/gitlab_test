<script>
import { s__ } from '~/locale';
import { GlForm, GlFormSelect, GlFormInput, GlNewDropdown, GlNewDropdownItem } from '@gitlab/ui';
import NetworkPolicy from '../../lib/network_policy';
import {
  RuleDirectionInbound,
  RuleDirectionOutbound,
  EndpointMatchModeAny,
  EndpointMatchModeLabel,
  RuleTypeEndpoint,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
  EntityTypes,
  PortMatchModeAny,
  PortMatchModePortProtocol,
} from '../../lib/constants';
import { RuleTypeNetwork } from './constants';

export default {
  components: {
    GlForm,
    GlFormSelect,
    GlFormInput,
    GlNewDropdown,
    GlNewDropdownItem,
  },
  props: {
    policy: {
      type: Object,
      required: true,
      validator: policy => policy instanceof NetworkPolicy,
    },
    ruleIndex: {
      type: Number,
      required: true,
    },
    endpointSelectorDisabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return { ruleType: RuleTypeNetwork };
  },
  computed: {
    ruleContainer() {
      return this.policy.rules[this.ruleIndex];
    },
    rule() {
      return this.ruleContainer.rule;
    },
    shouldShowEndpointLabels() {
      return this.policy.endpointMatchMode === EndpointMatchModeLabel;
    },
    modeLabelText() {
      return this.rule.direction === RuleDirectionInbound
        ? s__('NetworkPolicies|and is inbound from a')
        : s__('NetworkPolicies|and is outbound to a');
    },
    allowEditEndpointRule() {
      return this.ruleContainer.ruleType === RuleTypeEndpoint;
    },
    allowEditEntityRule() {
      return this.ruleContainer.ruleType === RuleTypeEntity;
    },
    allowEditCIDRRule() {
      return this.ruleContainer.ruleType === RuleTypeCIDR;
    },
    allowEditFQDNRule() {
      return this.ruleContainer.ruleType === RuleTypeFQDN;
    },
    selectedEntities() {
      if (!this.allowEditEntityRule || this.rule.entities.length === 0) {
        return s__('NetworkPolicies|None selected');
      }

      const { entities } = this.rule;
      if (entities.includes(EntityTypes.ALL)) return s__('NetworkPolicies|All selected');

      if (entities.length > 3) return `${entities.length} ${s__('NetworkPolicies|selected')}`;

      return entities.join(', ');
    },
    shouldShowPorts() {
      return this.rule.portMatchMode === PortMatchModePortProtocol;
    },
  },
  methods: {
    selectEntity(entity) {
      if (!this.allowEditEntityRule) return;

      const { entities } = this.rule;
      if (entities.includes(entity)) {
        this.rule.entities = entities.filter(e => e !== entity);
      } else {
        this.rule.entities = [...entities, entity];
      }
    },
    isSelectedEntity(entity) {
      if (!this.allowEditEntityRule) return false;

      const { entities } = this.rule;
      if (entities.includes(EntityTypes.ALL)) return true;

      return entities.includes(entity);
    },
  },
  ruleTypes: [{ value: RuleTypeNetwork, text: s__('NetworkPolicies|Network Traffic') }],
  trafficDirections: [
    { value: RuleDirectionInbound, text: s__('NetworkPolicies|inbound to') },
    { value: RuleDirectionOutbound, text: s__('NetworkPolicies|outbound from') },
  ],
  endpointMatchModes: [
    { value: EndpointMatchModeAny, text: s__('NetworkPolicies|any pod') },
    { value: EndpointMatchModeLabel, text: s__('NetworkPolicies|pods with labels') },
  ],
  ruleModes: [
    { value: RuleTypeEndpoint, text: s__('NetworkPolicies|pod with labels') },
    { value: RuleTypeEntity, text: s__('NetworkPolicies|entity') },
    { value: RuleTypeCIDR, text: s__('NetworkPolicies|IP/subnet') },
    { value: RuleTypeFQDN, text: s__('NetworkPolicies|domain name') },
  ],
  entities: Object.keys(EntityTypes).map(type => ({
    value: EntityTypes[type],
    text: EntityTypes[type],
  })),
  portMatchModes: [
    { value: PortMatchModeAny, text: s__('NetworkPolicies|any port') },
    { value: PortMatchModePortProtocol, text: s__('NetworkPolicies|ports/protocols') },
  ],
};
</script>

<template>
  <div
    class="gl-bg-gray-10 gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base px-3 pt-3"
  >
    <gl-form inline>
      <label for="ruleType" class="text-uppercase gl-font-lg gl-mr-4 gl-mb-5!">{{
        s__('NetworkPolicies|If')
      }}</label>
      <gl-form-select
        id="ruleType"
        class="gl-mr-4 gl-mb-5!"
        :value="ruleType"
        :options="$options.ruleTypes"
      />

      <label for="direction" class="gl-mr-4 gl-mb-5!">{{ s__('NetworkPolicies|is') }}</label>
      <gl-form-select
        id="direction"
        v-model="rule.direction"
        class="gl-mr-4 gl-mb-5"
        :options="$options.trafficDirections"
      />

      <gl-form-select
        v-model="policy.endpointMatchMode"
        data-testid="endpoint-match-mode"
        class="gl-mr-4 gl-mb-5"
        :disabled="endpointSelectorDisabled"
        :options="$options.endpointMatchModes"
      />
      <gl-form-input
        v-if="shouldShowEndpointLabels"
        v-model="policy.endpointLabels"
        data-testid="endpoint-labels"
        class="gl-mr-4 gl-mb-5"
        :placeholder="s__('NetworkPolicies|key:value')"
        :disabled="endpointSelectorDisabled"
      />

      <label for="ruleMode" class="gl-mr-4 gl-mb-5!">{{ modeLabelText }}</label>
      <gl-form-select
        id="ruleMode"
        v-model="ruleContainer.ruleType"
        class="gl-mr-4 gl-mb-5"
        :options="$options.ruleModes"
      />

      <gl-form-input
        v-if="allowEditEndpointRule"
        v-model="rule.matchLabels"
        data-testid="rule-endpoint"
        class="gl-mr-4 gl-mb-5"
        :placeholder="s__('NetworkPolicies|key:value')"
      />
      <gl-new-dropdown
        v-if="allowEditEntityRule"
        data-testid="rule-entity"
        class="gl-mr-4 gl-mb-5"
        :text="selectedEntities"
        multiple
      >
        <gl-new-dropdown-item
          v-for="entity in $options.entities"
          :key="entity.value"
          is-check-item
          :is-checked="isSelectedEntity(entity.value)"
          @click="selectEntity(entity.value)"
          >{{ entity.text }}</gl-new-dropdown-item
        >
      </gl-new-dropdown>
      <gl-form-input
        v-if="allowEditCIDRRule"
        v-model="rule.cidr"
        data-testid="rule-cidr"
        class="gl-mr-4 gl-mb-5"
        :placeholder="s__('NetworkPolicies|0.0.0.0/24')"
      />
      <gl-form-input
        v-if="allowEditFQDNRule"
        v-model="rule.fqdn"
        data-testid="rule-fqdn"
        class="gl-mr-4 gl-mb-5"
        :placeholder="s__('NetworkPolicies|remote-service.com')"
      />

      <label for="ports" class="gl-mr-4 gl-mb-5!">{{ s__('NetworkPolicies|on') }}</label>
      <gl-form-select
        id="portMatch"
        v-model="rule.portMatchMode"
        class="gl-mr-4 gl-mb-5"
        :options="$options.portMatchModes"
      />
      <gl-form-input
        v-if="shouldShowPorts"
        v-model="rule.ports"
        data-testid="ports"
        class="gl-mr-4 gl-mb-5"
        :placeholder="s__('NetworkPolicies|80/tcp')"
      />
    </gl-form>
  </div>
</template>
