import { shallowMount } from '@vue/test-utils';
import echarts from 'echarts';
import Chart from '../../../components/charts/chart/chart.vue';

const defaultHeight = 400;

jest.mock('echarts', () => ({
  init: jest.fn(() => ({
    setOption: jest.fn(),
    resize: jest.fn(),
  })),
}));

describe('chart component', () => {
  const options = {};
  const mountArgs = [Chart, { propsData: { options: {} } }];
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(...mountArgs);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('initializes chart using $refs.chart', () => {
    expect(echarts.init).toHaveBeenCalledWith(wrapper.find({ ref: 'chart' }).element, null, {
      renderer: wrapper.props().renderer,
    });
  });

  it('emits "created" after initializing chart', () => {
    expect(wrapper.emitted('created')).toEqual([[wrapper.vm.chart]]);
  });

  describe('custom sizing', () => {
    const width = 1234;
    const height = 123;

    it('sets chart to custom width and height if specified', () => {
      wrapper = shallowMount(Chart, { propsData: { options: {}, width, height } });

      expect(wrapper.vm.chart.resize).toHaveBeenCalledWith({ width, height });
    });

    it('sets chart to custom width if specified', () => {
      wrapper = shallowMount(Chart, { propsData: { options: {}, width } });

      expect(wrapper.vm.chart.resize).toHaveBeenCalledWith({ width, height: defaultHeight });
    });

    it('sets chart to custom height if specified', () => {
      wrapper = shallowMount(Chart, { propsData: { options: {}, height } });

      expect(wrapper.vm.chart.resize).toHaveBeenCalledWith({ width: 'auto', height });
    });
  });

  describe('methods', () => {
    describe('draw method', () => {
      it('sets chart options', () => {
        wrapper.vm.draw();

        expect(wrapper.vm.chart.setOption).toHaveBeenCalledWith(options);
      });

      it('emits chart updated after drawing', () => {
        wrapper.vm.draw();
        const { chart } = wrapper.vm;

        expect(wrapper.emitted('updated')).toEqual([[chart], [chart]]);
      });
    });

    describe('setChartSize method', () => {
      it('sets chart size', () => {
        wrapper.vm.setChartSize();

        expect(wrapper.vm.chart.resize).toHaveBeenCalledWith({
          height: defaultHeight,
          width: 'auto',
        });
      });
    });
  });
});
