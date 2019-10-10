import { shallowMount } from '@vue/test-utils';
import { green500, orange500, red500 } from '@gitlab/ui/scss_to_js/scss_variables';
import { hexToRgb } from '~/lib/utils/color_utils';
import Component from 'ee/analytics/code_analytics/components/code_hotspots_chart_legend';

const green = hexToRgb(green500);
const orange = hexToRgb(orange500);
const red = hexToRgb(red500);

const opacity = [0.2, 0.4, 0.6, 0.8];

const DEFAULT_COLORS = [
  `rgba(${green}, ${opacity[0]})`,
  `rgba(${green}, ${opacity[1]})`,
  `rgba(${green}, ${opacity[2]})`,
  `rgba(${green}, ${opacity[3]})`,
  `rgba(${orange}, ${opacity[3]})`,
  `rgba(${red}, ${opacity[3]})`,
];

const createComponent = () =>
  shallowMount(Component, {
    sync: false,
    propsData: {
      colors: DEFAULT_COLORS,
      title: 'Number of commits (Darker means more)',
    },
  });

describe('CodeHotspotsChartLegend Component', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent();
  });

  it('matches the snapshot', () => {
    expect(vm.element).toMatchSnapshot();
  });
});
