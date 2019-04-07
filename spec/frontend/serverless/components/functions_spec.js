import Vuex from 'vuex';
import AxiosMockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import functionsComponent from '~/serverless/components/functions.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import ServerlessStore from '~/serverless/stores/serverless_store';

import { mockServerlessFunctions } from '../mock_data';

const createComponent = (
  functions,
  installed = true,
  loadingData = true,
  hasFunctionData = true,
) => {
  const component = Vue.extend(functionsComponent);

  return mountComponent(component, {
    functions,
    installed,
    clustersPath: '/testClusterPath',
    helpPath: '/helpPath',
    loadingData,
    hasFunctionData,
  });
};

describe('functionsComponent', () => {
  it('should render empty state when Knative is not installed', () => {
    const vm = createComponent({}, false);

    expect(vm.$el.querySelector('div.row').classList.contains('js-empty-state')).toBe(true);
    expect(vm.$el.querySelector('h4.state-title').innerHTML.trim()).toEqual(
      'Getting started with serverless',
    );

    vm.$destroy();
  });

  it('should render a loading component', () => {
    const vm = createComponent({});

    expect(vm.$el.querySelector('.gl-responsive-table-row')).not.toBe(null);
    expect(vm.$el.querySelector('div.animation-container')).not.toBe(null);
  });

  it('should render empty state when there is no function data', () => {
    const vm = createComponent({}, true, false, false);

    expect(
      vm.$el.querySelector('.empty-state, .js-empty-state').classList.contains('js-empty-state'),
    ).toBe(true);

    expect(vm.$el.querySelector('h4.state-title').innerHTML.trim()).toEqual(
      'No functions available',
    );

    vm.$destroy();
  });

  it('should render the functions list', () => {
    const statusPath = 'statusPath';
    const axiosMock = new AxiosMockAdapter(axios);
    axiosMock.onGet(statusPath).reply(200);

    component = shallowMount(functionsComponent, {
      localVue,
      store,
      propsData: {
        installed: true,
        clustersPath: 'clustersPath',
        helpPath: 'helpPath',
        statusPath,
      },
      sync: false,
    });

    component.vm.$store.dispatch('receiveFunctionsSuccess', mockServerlessFunctions);

    expect(vm.$el.querySelector('div.groups-list-tree-container')).not.toBe(null);
    expect(vm.$el.querySelector('#env-global').classList.contains('has-children')).toBe(true);
  });
});
