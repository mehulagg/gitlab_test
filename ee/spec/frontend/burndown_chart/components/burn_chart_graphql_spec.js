import { shallowMount } from '@vue/test-utils';
import BurnCharts from 'ee/burndown_chart/components/burn_charts.vue';
import BurnChartsGraphql from 'ee/burndown_chart/components/burn_charts_graphql.vue';

describe('GraphQL-powered burn charts', () => {
  let wrapper;

  const defaultProps = {
    startDate: '2019-08-07T00:00:00.000Z',
    dueDate: '2019-09-09T00:00:00.000Z',
    iterationId: '4',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(BurnChartsGraphql, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  const findBurnCharts = () => wrapper.find(BurnCharts);

  it('renders without error', () => {
    createComponent();

    expect(findBurnCharts().exists()).toBe(true);
  });
});
