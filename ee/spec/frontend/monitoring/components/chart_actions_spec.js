import { shallowMount, createLocalVue } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { GlModal, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';

import ChartActions from 'ee/monitoring/components/chart_actions.vue';
import AlertWidget from 'ee/monitoring/components/alert_widget.vue';

describe('ChartActions', () => {
  let Component;
  let mock;
  let store;
  let vm;
  const localVue = createLocalVue();

  beforeEach(() => {
    window.gon = {
      ...window.gon,
      ee: true,
    };

    mock = new MockAdapter(axios);
    Component = localVue.extend(ChartActions);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('metrics with alert', () => {
    describe('with license', () => {
      beforeEach(() => {
        vm = shallowMount(ChartActions, {
          propsData: {
            graphData: {},
            hasMetrics: true,
            prometheusAlertsAvailable: true,
            alertsEndpoint: '/endpoint',
          },
          store,
        });
      });

      it('shows alert widget and dropdown item', () => {
        expect(vm.find(AlertWidget).exists()).toBe(true);
        expect(
          vm
            .findAll(GlDropdownItem)
            .filter(i => i.text() === 'Alerts')
            .exists(),
        ).toBe(true);
      });

      // it('shows More actions dropdown on chart', done => {
      //   setTimeout(() => {
      //     expect(
      //       vm
      //         .findAll(GlDropdown)
      //         .filter(d => d.attributes('data-original-title') === 'More actions')
      //         .exists(),
      //     ).toBe(true);

      //     done();
      //   });
      // });
    });

    // describe('without license', () => {
    //   beforeEach(() => {
    //     vm = shallowMount(Component, {
    //       propsData: {
    //         graphData: {},
    //         hasMetrics: true,
    //         prometheusAlertsAvailable: false,
    //         alertsEndpoint: '/endpoint',
    //       },
    //     });
    //   });

    //   it('does not show alert widget', done => {
    //     setTimeout(() => {
    //       expect(vm.find(AlertWidget).exists()).toBe(false);
    //       expect(
    //         vm
    //           .findAll(GlDropdownItem)
    //           .filter(i => i.text() === 'Alerts')
    //           .exists(),
    //       ).toBe(false);

    //       done();
    //     });
    //   });

    //   it('hides More actions dropdown on chart', done => {
    //     setTimeout(() => {
    //       expect(
    //         vm
    //           .findAll(GlDropdown)
    //           .filter(d => d.attributes('data-original-title') === 'More actions')
    //           .exists(),
    //       ).toBe(false);

    //       done();
    //     });
    //   });
    // });
  });
});
