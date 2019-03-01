import MRPopover from '~/mr_popover/components/mr_popover';
import { shallowMount } from '@vue/test-utils';

describe('MR Popover', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(MRPopover, {
      propsData: {
        target: document.createElement('a'),
        projectPath: 'foo/bar',
        mergeRequestIID: '1',
        mergeRequestTitle: 'MR Title',
      },
      mocks: {
        $apollo: {
          loading: false,
        },
      },
    });
  });

  it('shows skeleton-loader while apollo is loading', () => {
    wrapper.vm.$apollo.loading = true;

    expect(wrapper.element).toMatchSnapshot();
  });

  describe('loaded state', () => {
    it('matches the snapshot', () => {
      wrapper.setData({
        mergeRequest: {
          state: 'opened',
          ciStatus: 'SUCCESS ',
          stateHumanName: 'Open',
          createdAt: new Date(),
        },
      });

      expect(wrapper.element).toMatchSnapshot();
    });

    it('does not show CI Icon if there is no pipeline data', () => {
      wrapper.setData({
        state: 'opened',
        ciStatus: null,
        stateHumanName: 'Open',
        title: 'Merge Request Title',
        createdAt: new Date(),
      });

      expect(wrapper.contains('ciicon-stub')).toBe(false);
    });
  });
});
