import { shallowMount } from '@vue/test-utils';
import BurnCharts from 'ee/burndown_chart/components/burn_charts.vue';
import BurnChartsGraphql from 'ee/burndown_chart/components/burn_charts_graphql.vue';

describe('GraphQL-powered burn charts', () => {
  let wrapper;

  const defaultProps = {
    startDate: '2019-09-07',
    dueDate: '2019-09-09',
    iterationId: '4',
  };

  const createComponent = ({ props = {}, data = {} } = {}) => {
    wrapper = shallowMount(BurnChartsGraphql, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      data() {
        return data;
      },
    });
  };

  const findBurnCharts = () => wrapper.find(BurnCharts);

  it('passes computed values to burn-charts component', () => {
    createComponent();

    const { startDate, dueDate } = defaultProps;
    const { openIssuesCount, openIssuesWeight, burnupScope } = wrapper.vm;

    expect(findBurnCharts().props()).toEqual({
      startDate,
      dueDate,
      openIssuesCount,
      openIssuesWeight,
      burnupScope,
    });
  });

  // add some tests for this method because it is complex and error-prone
  describe('burnupData', () => {
    it('fills in gaps in dates with values from previous days', () => {
      const day1 = {
        date: '2019-09-07',
        scopeCount: 10,
        scopeWeight: 20,
        completedCount: 5,
        completedWeight: 10,
      };
      const day2 = {
        ...day1,
        date: '2019-09-08',
      };
      const day3 = {
        ...day2,
        date: '2019-09-09',
      };
      const day4 = {
        date: '2019-09-10',
        scopeCount: 12,
        scopeWeight: 24,
        completedCount: 8,
        completedWeight: 18,
      };

      createComponent({
        data: {
          sparseBurnupData: [day1, day4],
        },
      });

      expect(wrapper.vm.burnupData).toEqual([day1, day2, day3, day4]);
    });
  });
});
