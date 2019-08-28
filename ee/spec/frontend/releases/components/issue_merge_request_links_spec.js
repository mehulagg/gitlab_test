import { shallowMount } from '@vue/test-utils';
import IssueMergeRequestLinks from 'ee/releases/components/issue_merge_request_links.vue';
import _ from 'underscore';
import { milestones } from '../mock_data';

describe('Milestone list', () => {
  let wrapper;

  const factory = milestonesProp => {
    wrapper = shallowMount(IssueMergeRequestLinks, {
      propsData: {
        milestones: milestonesProp,
      },
      sync: false,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('render the expected text', () => {
    factory(milestones);

    expect(wrapper.text()).toBe('View Issues or Merge Requests in this release');
  });
});
