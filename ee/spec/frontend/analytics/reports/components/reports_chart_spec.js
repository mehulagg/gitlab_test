import Vuex from 'vuex';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import { GlColumnChart } from '@gitlab/ui/dist/charts';
import httpStatusCodes from '~/lib/utils/http_status';
import ReportsChart from 'ee/analytics/reports/components/reports_chart.vue';
import createStore from 'ee/analytics/reports/store';
import { configData, seriesData } from 'ee_jest/analytics/reports/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ReportsChart', () => {
  let wrapper;
  let mock;

  const createComponent = () => {
    const component = shallowMount(ReportsChart, {
      localVue,
      store: createStore(),
    });

    component.vm.$store.dispatch('page/receivePageConfigDataSuccess', configData);

    return component;
  };

  const findGlLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findChart = () => wrapper.find(GlColumnChart);

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet().reply(httpStatusCodes.OK, seriesData);
  });

  afterEach(() => {
    mock.restore();

    wrapper.destroy();
    wrapper = null;
  });

  describe('loading icon', () => {
    it('displays the icon while series data is being retrieved', async () => {
      wrapper = createComponent();

      await wrapper.vm.$nextTick();

      expect(findGlLoadingIcon().exists()).toBe(true);
    });

    it('hides the icon once the series data has being retrieved', async () => {
      wrapper = createComponent();

      wrapper.vm.$store.dispatch('chart/receiveChartSeriesDataSuccess', seriesData);

      await wrapper.vm.$nextTick();

      expect(findGlLoadingIcon().exists()).toBe(false);
    });
  });

  describe('displaying of chart', () => {
    it('does not display while the data is being retrieved', async () => {
      wrapper = createComponent();

      await wrapper.vm.$nextTick();

      expect(findChart().exists()).toBe(false);
    });

    it('displays once the data has being retrieved', async () => {
      wrapper = createComponent();

      wrapper.vm.$store.dispatch('chart/receiveChartSeriesDataSuccess', seriesData);

      await wrapper.vm.$nextTick();

      expect(findChart().exists()).toBe(true);
    });
  });
});
