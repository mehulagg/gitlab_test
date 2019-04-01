import Vue from 'vue';
import axios from '~/lib/utils/axios_utils';
import MockAdapter from 'axios-mock-adapter';
import InsightsPage from 'ee/insights/components/insights_page.vue';
import { createStore } from 'ee/insights/stores';
import { mountComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import { chartInfo, pageInfo, pageInfoNoCharts, chartData } from '../mock_data';

describe('Insights page component', () => {
  let component;
  let store;
  let mock;
  let Component;

  beforeEach(() => {
    store = createStore();
    spyOn(store, 'dispatch').and.stub();
    mock = new MockAdapter(axios);
    Component = Vue.extend(InsightsPage);
  });

  afterEach(() => {
    component.$destroy();
    mock.restore();
  });

  describe('no chart config available', () => {
    it('shows an empty state', done => {
      component = mountComponentWithStore(Component, {
        store,
        props: {
          queryEndpoint: `${gl.TEST_HOST}/query`,
          pageConfig: pageInfoNoCharts,
        },
      });

      expect(component.$el.querySelector('.empty-state')).not.toBe(null);
      done();
    });
  });

  describe('charts configured', () => {
    beforeEach(() => {
      component = mountComponentWithStore(Component, {
        store,
        props: {
          queryEndpoint: `${gl.TEST_HOST}/query`,
          pageConfig: pageInfo,
        },
      });
    });

    it('fetches chart data when mounted', done => {
      expect(store.dispatch).toHaveBeenCalledWith('insights/fetchChartData', {
        endpoint: `${gl.TEST_HOST}/query`,
        chart: chartInfo,
      });
      done();
    });

    describe('when charts loading', () => {
      beforeEach(() => {
        component.$store.state.insights.pageLoading = true;
      });

      it('renders loading state', done => {
        Vue.nextTick(() => {
          expect(
            component.$el.querySelector('.insights-page-container .insights-chart-loading'),
          ).not.toBe(null);
          done();
        });
      });

      it('does not display chart area', done => {
        Vue.nextTick(() => {
          expect(component.$el.querySelector('.insights-page-container .insights-charts')).toBe(
            null,
          );
          done();
        });
      });
    });

    describe('when charts loaded', () => {
      beforeEach(() => {
        component.$store.state.insights.pageLoading = false;
        component.$store.state.insights.store[chartInfo.title] = {
          type: chartInfo.type,
          data: chartData,
          loaded: true,
        };
      });

      it('displays correct chart post load', done => {
        setTimeout(() => {
          component.$nextTick(() => {
            const chartCanvas = component.$el.querySelectorAll(
              '.insights-page-container .insights-charts .insights-chart canvas',
            );

            expect(chartCanvas.length).toEqual(1);
            expect(chartCanvas[0].classList).toContain('bar');
            done();
          });
        });
      });
    });

    describe('chart data retrieve error', () => {
      const error = 'my error';

      beforeEach(() => {
        component.$store.state.insights.pageLoading = false;
        component.$store.state.insights.store[chartInfo.title] = {
          type: chartInfo.type,
          data: null,
          loaded: false,
          error,
        };
      });

      it('displays info about the error', done => {
        setTimeout(() => {
          component.$nextTick(() => {
            const errorElements = component.$el.querySelectorAll(
              '.insights-page-container .insights-charts .insights-chart .empty-state',
            );

            expect(errorElements.length).toEqual(1);
            expect(errorElements[0].textContent).toContain(error);
            done();
          });
        });
      });
    });

    describe('pageConfig changes', () => {
      it('reflects new state', done => {
        // Establish rendered state
        setTimeout(done);
        component.$nextTick();

        component.pageConfig = pageInfoNoCharts;

        component.$nextTick(() => {
          expect(component.$el.querySelector('.empty-state')).not.toBe(null);
          done();
        });
      });
    });
  });
});
