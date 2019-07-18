import { shallowMount, createLocalVue } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { GlModal } from '@gitlab/ui';
import Dashboard from 'ee/monitoring/components/dashboard.vue';
import { createStore } from '~/monitoring/stores';
import * as types from '~/monitoring/stores/mutation_types';
import axios from '~/lib/utils/axios_utils';
import {
  mockApiEndpoint,
  metricsNewGroupsAPIResponse,
  mockedQueryResultPayload,
  environmentData,
} from 'spec/monitoring/mock_data';
import propsData from 'spec/monitoring/dashboard_spec';
import AlertWidget from 'ee/monitoring/components/alert_widget.vue';
import CustomMetricsFormFields from 'ee/custom_metrics/components/custom_metrics_form_fields.vue';

function setupWrapperStore(wrapper) {
  wrapper.vm.$store.commit(
    `monitoringDashboard/${types.RECEIVE_METRICS_DATA_SUCCESS}`,
    metricsNewGroupsAPIResponse,
  );
  wrapper.vm.$store.commit(
    `monitoringDashboard/${types.SET_QUERY_RESULT}`,
    mockedQueryResultPayload,
  );
  wrapper.vm.$store.commit(
    `monitoringDashboard/${types.RECEIVE_ENVIRONMENTS_DATA_SUCCESS}`,
    environmentData,
  );
}

describe('Dashboard', () => {
  let Component;
  let mock;
  let store;
  let wrapper;
  const localVue = createLocalVue();

  beforeEach(() => {
    setFixtures(`
      <div class="prometheus-graphs"></div>
      <div class="layout-page"></div>
    `);

    window.gon = {
      ...window.gon,
      ee: true,
    };

    store = createStore();
    mock = new MockAdapter(axios);
    mock.onGet(mockApiEndpoint).reply(200, metricsNewGroupsAPIResponse);
    Component = localVue.extend(Dashboard);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('metrics with alert', () => {
    describe('with license', () => {
      beforeEach(() => {
        wrapper = shallowMount(Component, {
          propsData: {
            ...propsData,
            hasMetrics: true,
            prometheusAlertsAvailable: true,
            alertsEndpoint: '/endpoint',
          },
          store,
        });
      });

      it('shows alert widget', done => {
        setupWrapperStore(wrapper);

        localVue
          .nextTick()
          .then(() => {
            expect(wrapper.find(AlertWidget).exists()).toBe(true);
            done();
          })
          .catch(done.fail);
      });
    });

    describe('without license', () => {
      beforeEach(() => {
        wrapper = shallowMount(Component, {
          propsData: {
            ...propsData,
            hasMetrics: true,
            prometheusAlertsAvailable: false,
            alertsEndpoint: '/endpoint',
          },
          store,
        });
      });

      it('does not show alert widget', done => {
        setupWrapperStore(wrapper);

        localVue
          .nextTick()
          .then(() => {
            expect(wrapper.find(AlertWidget).exists()).toBe(false);
            done();
          })
          .catch(done.fail);
      });
    });
  });

  describe('add custom metrics', () => {
    describe('when not available', () => {
      beforeEach(() => {
        wrapper = shallowMount(Component, {
          propsData: {
            ...propsData,
            customMetricsAvailable: false,
            customMetricsPath: '/endpoint',
            hasMetrics: true,
            prometheusAlertsAvailable: true,
            alertsEndpoint: '/endpoint',
          },
          store,
        });
      });

      it('does not render add button on the dashboard', done => {
        setupWrapperStore(wrapper);

        localVue
          .nextTick()
          .then(() => {
            expect(wrapper.element.querySelector('.js-add-metric-button')).toBe(null);
            done();
          })
          .catch(done.fail);
      });
    });

    describe('when available', () => {
      beforeEach(done => {
        wrapper = shallowMount(Component, {
          propsData: {
            ...propsData,
            customMetricsAvailable: true,
            customMetricsPath: '/endpoint',
            hasMetrics: true,
            prometheusAlertsAvailable: true,
            alertsEndpoint: '/endpoint',
          },
          store,
        });

        setupWrapperStore(wrapper);

        localVue
          .nextTick()
          .then(done)
          .catch(done.fail);
      });

      it('renders add button on the dashboard', () => {
        expect(wrapper.element.querySelector('.js-add-metric-button').innerText).toContain(
          'Add metric',
        );
      });

      it('uses modal for custom metrics form', () => {
        expect(wrapper.find(GlModal).exists()).toBe(true);
        expect(wrapper.find(GlModal).attributes().modalid).toBe('add-metric');
      });

      it('renders custom metrics form fields', () => {
        expect(wrapper.find(CustomMetricsFormFields).exists()).toBe(true);
      });
    });
  });
});
