import { shallowMount } from '@vue/test-utils';
import Component from 'ee/analytics/code_analytics/components/code_hotspots_chart';
import { codeHotspotsTransformedData, tooltipVerticalOffset } from '../mock_data';

const createComponent = () =>
  shallowMount(Component, {
    sync: false,
    propsData: {
      data: codeHotspotsTransformedData,
      legendTitle: 'Number of commits (Darker means more)',
    },
  });

describe('CodeHotspotsChart Component', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('methods', () => {
    describe('updateTooltipText', () => {
      it('sets the tooltip title', () => {
        const file = codeHotspotsTransformedData[0];

        wrapper.vm.updateTooltipText({ data: file });

        expect(wrapper.vm.tooltipTitle).toStrictEqual({
          link: file.link,
          name: file.name,
        });
      });

      it('sets the tooltip content', () => {
        const file = codeHotspotsTransformedData[0];

        wrapper.vm.updateTooltipText({ data: file });

        expect(wrapper.vm.tooltipContent).toStrictEqual({
          title: 'Commits',
          value: file.value,
        });
      });
    });

    describe('displayAndPositionTooltip', () => {
      it('sets the tooltip position correctly', () => {
        const y = 50;

        wrapper.vm.displayAndPositionTooltip({ zrX: 50, zrY: 50 });

        expect(wrapper.vm.tooltipPosition).toStrictEqual({
          left: '50px',
          top: `${y - tooltipVerticalOffset}px`,
        });
      });
    });
  });
});
