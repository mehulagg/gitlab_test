import { shallowMount } from '@vue/test-utils';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
import BurnupChart from 'ee/burndown_chart/components/burnup_chart.vue';

describe('Burnup chart', () => {
  let wrapper;

  const defaultProps = {
    startDate: '2019-08-07T00:00:00.000Z',
    dueDate: '2019-09-09T00:00:00.000Z',
    openIssuesCount: [],
    openIssuesWeight: [],
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(BurnupChart, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      stubs: {
        ResizableChartContainer,
      },
    });
  };

  describe('with single point', () => {
    it('does not show guideline', () => {
      createComponent({
        openIssuesCount: [{ '2019-08-07T00:00:00.000Z': 100 }],
      });

      const data = wrapper.find(GlLineChart).props('data');
      expect(data.length).toBe(1);
      expect(data[0].name).toBe('Total');
    });
  });

  describe('with multiple points', () => {
    it('shows guideline', () => {
      createComponent({
        openIssuesCount: [
          { '2019-08-07T00:00:00.000Z': 100 },
          { '2019-08-08T00:00:00.000Z': 99 },
          { '2019-09-08T00:00:00.000Z': 1 },
        ],
      });

      const data = wrapper.find(GlLineChart).props('data');
      expect(data.length).toBe(1);
    });
  });
});
