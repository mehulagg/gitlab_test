import Vue from 'vue';
import featureFlagsTableComponent from 'ee/feature_flags/components/feature_flags_table.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { trimText } from 'spec/helpers/text_helper';
import { featureFlag } from '../mock_data';

describe('Feature Flag table', () => {
  let Component;
  let vm;

  beforeEach(() => {
    Component = Vue.extend(featureFlagsTableComponent);
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('Should render a table', () => {
    vm = mountComponent(Component, {
      featureFlags: [featureFlag],
      csrfToken: 'fakeToken',
    });

    expect(vm.$el.getAttribute('class')).toContain('table-holder');
  });

  it('Should render rows', () => {
    expect(vm.$el.querySelector('.gl-responsive-table-row')).not.toBeNull();
  });

  it('Should render a status column', () => {
    const status = featureFlag.active ? 'Active' : 'Inactive';

    expect(vm.$el.querySelector('.js-feature-flag-status')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-status').textContent.trim()).toEqual(status);
  });

  it('Should render a feature flag column', () => {
    expect(vm.$el.querySelector('.js-feature-flag-title')).not.toBeNull();
    expect(vm.$el.querySelector('.feature-flag-name').textContent.trim()).toEqual(featureFlag.name);
    expect(vm.$el.querySelector('.feature-flag-description').textContent.trim()).toEqual(
      featureFlag.description,
    );
  });

  it('should render a environments specs column', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments');

    expect(envColumn).not.toBeNull();
    expect(envColumn.textContent.trim()).toContain(featureFlag.scopes[0].environment_scope);
    expect(envColumn.textContent.trim()).toContain(featureFlag.scopes[1].environment_scope);
  });

  it('should render a environments specs badge with inactive class', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments');

    expect(envColumn.querySelector('.badge-inactive').textContent.trim()).toContain(
      featureFlag.scopes[1].environment_scope,
    );
  });

  it('should render a environments specs badge with active class', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments');

    expect(envColumn.querySelector('.badge-active').textContent.trim()).toContain(
      featureFlag.scopes[0].environment_scope,
    );
  });

  it('renders an environment spec badge with a percentage rollout', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments .js-badge:last-child');
    const scope = featureFlag.scopes[1];

    expect(trimText(envColumn.textContent)).toContain(
      `${scope.environment_scope}: ${scope.strategy.parameters.percentage}%`,
    );
  });

  it('Should render an actions column', () => {
    expect(vm.$el.querySelector('.table-action-buttons')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-delete-button')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-edit-button')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-edit-button').getAttribute('href')).toEqual(
      featureFlag.edit_path,
    );
  });

  describe('.badgeText', () => {
    it('returns text for a scope with a gradualRolloutUserId strategy', () => {
      const scope = {
        environment_scope: 'production',
        strategy: {
          name: 'gradualRolloutUserId',
          parameters: {
            groupId: 'default',
            percentage: '40',
          },
        },
      };

      expect(vm.badgeText(scope)).toEqual('production: 40%');
    });

    it('returns text for a scope with a default strategy', () => {
      const scope = {
        environment_scope: 'staging',
        strategy: {
          name: 'default',
          parameters: {},
        },
      };

      expect(vm.badgeText(scope)).toEqual('staging');
    });

    it('returns text for a scope without a strategy', () => {
      const scope = { environment_scope: 'review' };

      expect(vm.badgeText(scope)).toEqual('review');
    });
  });
});
