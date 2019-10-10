import { shallowMount } from '@vue/test-utils';
import Component from 'ee/vue_shared/components/charts/treemap/treemap_chart_legend';
import { DEFAULT_COLORS } from 'ee/vue_shared/components/charts/treemap/constants';

const createComponent = () =>
  shallowMount(Component, {
    sync: false,
    propsData: {
      colors: DEFAULT_COLORS,
      title: 'Number of commits (Darker means more)',
    },
  });

describe('TreemapChartLegend Component', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent();
  });

  it('matches the snapshot', () => {
    expect(vm.element).toMatchSnapshot();
  });
});
