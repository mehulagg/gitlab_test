import { createLocalVue, shallowMount } from '@vue/test-utils';
import MetricChart from 'ee/analytics/productivity_analytics/components/metric_chart.vue';
import { GlLoadingIcon, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

describe('MetricChart component', () => {
  let wrapper;

  const defaultProps = {
    title: 'My Chart',
    description: 'Test description',
  };

  const mockChart = 'mockChart';

  const metricTypes = [
    {
      key: 'time_to_merge',
      label: 'Time from last commit to merge',
    },
    {
      key: 'time_to_last_commit',
      label: 'Time from first comment to last commit',
    },
  ];

  const factory = (props = defaultProps) => {
    const localVue = createLocalVue();

    wrapper = shallowMount(localVue.extend(MetricChart), {
      localVue,
      sync: false,
      propsData: { ...props },
      slots: {
        default: mockChart,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findLoadingIndicator = () => wrapper.find(GlLoadingIcon);
  const findMetricDropdown = () => wrapper.find(GlDropdown);
  const findMetricDropdownItems = () => findMetricDropdown().findAll(GlDropdownItem);

  it('matches the snapshot', () => {
    factory();
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('template', () => {
    describe('when title and description exist', () => {
      beforeEach(() => {
        factory();
      });

      it('renders a title', () => {
        expect(wrapper.text()).toContain('My Chart');
      });

      it('renders a description', () => {
        expect(wrapper.text()).toContain('My Chart');
      });
    });

    describe("when title and description don't exist", () => {
      beforeEach(() => {
        factory({ title: null, description: null });
      });

      it("doesn't render a title", () => {
        expect(wrapper.text()).not.toContain('My Chart');
      });

      it("doesn't render a description", () => {
        expect(wrapper.text()).not.toContain('My Chart');
      });
    });

    describe('when isLoading is true', () => {
      it('renders a loading indicator', () => {
        factory({ isLoading: true });
        expect(findLoadingIndicator().exists()).toBe(true);
      });
    });

    describe('when isLoading is false', () => {
      it('does not render a loading indicator', () => {
        factory({ isLoading: false });
        expect(findLoadingIndicator().exists()).toBe(false);
      });

      describe('and metricTypes exist', () => {
        beforeEach(() => {
          factory({ isLoading: false, metricTypes });
        });

        it('renders a metric dropdown', () => {
          expect(findMetricDropdown().exists()).toBe(true);
        });

        it('renders a dropdown item for each item in metricTypes', () => {
          expect(findMetricDropdownItems().length).toBe(2);
        });

        it('should emit `metricTypeChange` event when dropdown item gets clicked', () => {
          jest.spyOn(wrapper.vm, '$emit');

          findMetricDropdownItems()
            .at(0)
            .vm.$emit('click');

          expect(wrapper.vm.$emit).toHaveBeenCalledWith('metricTypeChange', 'time_to_merge');
        });

        it('should set the `invisible` class on the icon of the first dropdown item', () => {
          wrapper.setProps({ selectedMetric: 'time_to_last_commit' });

          expect(
            findMetricDropdownItems()
              .at(0)
              .find(Icon)
              .classes(),
          ).toContain('invisible');
        });
      });

      describe('and chart data exists', () => {
        it('contains chart from slot', () => {
          factory({ isLoading: false, chartData: [[0, 1]] });
          expect(wrapper.find('.js-metric-chart').text()).toBe(mockChart);
        });
      });

      describe('and no chart data exists', () => {
        beforeEach(() => {
          factory({ isLoading: false, chartData: [] });
        });

        it('does not show the slot for the chart', () => {
          expect(wrapper.find('.js-metric-chart').text()).not.toBe(mockChart);
        });

        it('shows a "no data" info text', () => {
          expect(wrapper.text()).toContain(
            'There is no data for the selected metric available available.',
          );
        });
      });
    });
  });

  describe('computed', () => {
    describe('hasMetricTypes', () => {
      it('returns true if metricTypes exist', () => {
        factory({ metricTypes });
        expect(wrapper.vm.hasMetricTypes).toBe(true);
      });

      it('returns true if no metricTypes exist', () => {
        factory();
        expect(wrapper.vm.hasMetricTypes).toBe(false);
      });
    });

    describe('metricDropdownLabel', () => {
      describe('when a metric is selected', () => {
        it('returns the label of the currently selected metric', () => {
          factory({ metricTypes, selectedMetric: 'time_to_merge' });
          expect(wrapper.vm.metricDropdownLabel).toBe('Time from last commit to merge');
        });
      });

      describe('when no metric is selected', () => {
        it('returns the default dropdown label', () => {
          factory({ metricTypes });
          expect(wrapper.vm.metricDropdownLabel).toBe('Please select a metric');
        });
      });
    });

    describe('hasChartData', () => {
      describe('when chartData is an object', () => {
        it('returns true if chartData is not empty', () => {
          factory({ chartData: { 1: 0 } });
          expect(wrapper.vm.hasChartData).toBe(true);
        });

        it('returns false if chartData is empty', () => {
          factory({ chartData: {} });
          expect(wrapper.vm.hasChartData).toBe(false);
        });
      });

      describe('when chartData is an array', () => {
        it('returns true if chartData is not empty', () => {
          factory({ chartData: [[1, 0]] });
          expect(wrapper.vm.hasChartData).toBe(true);
        });

        it('returns false if chartData is empty', () => {
          factory({ chartData: [] });
          expect(wrapper.vm.hasChartData).toBe(false);
        });
      });
    });
  });

  describe('methods', () => {
    describe('isSelectedMetric', () => {
      it('returns true if the given key matches the selectedMetric prop', () => {
        factory({ selectedMetric: 'time_to_merge' });
        expect(wrapper.vm.isSelectedMetric('time_to_merge')).toBe(true);
      });
    });
  });
});
