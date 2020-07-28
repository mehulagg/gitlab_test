import NetworkPolicyRule from './network_policy_rule';
import { RuleDirectionInbound, EntityTypes } from './constants';

export default class NetworkPolicyRuleEntity extends NetworkPolicyRule {
  constructor(params) {
    super(params);
    this.entitiesList = [];
  }

  get entities() {
    return this.entitiesList;
  }

  set entities(entities) {
    if (
      entities.includes(EntityTypes.ALL) ||
      entities.length === Object.keys(EntityTypes).length - 1
    ) {
      this.entitiesList = [EntityTypes.ALL];
      return;
    }

    this.entitiesList = entities;
  }

  spec() {
    if (this.entities.length === 0) return super.spec();

    return {
      [this.direction === RuleDirectionInbound ? 'fromEntities' : 'toEntities']: this.entities,
      ...super.spec(),
    };
  }
}
