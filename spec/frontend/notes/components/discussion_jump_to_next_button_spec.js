import { shallowMount } from '@vue/test-utils';
import { GlButton } from 'gitlab-ui';
import JumpToNextDiscussionButton from '~/notes/components/discussion_jump_to_next_button.vue';
import { mockTracking } from '../../helpers/tracking_helper';

describe('JumpToNextDiscussionButton', () => {
  const fromDiscussionId = 'abc123';
  let wrapper;
  let trackingSpy;
  let jumpFn;

  const findButton = () => wrapper.find(GlButton);

  beforeEach(() => {
    jumpFn = jest.fn();
    wrapper = shallowMount(JumpToNextDiscussionButton, {
      propsData: { fromDiscussionId },
    });
    wrapper.setMethods({ jumpToNextRelativeDiscussion: jumpFn });

    trackingSpy = mockTracking('_category_', wrapper.element, jest.spyOn);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches the snapshot', () => {
    expect(wrapper.vm.$el).toMatchSnapshot();
  });

  it('calls jumpToNextRelativeDiscussion when clicked', () => {
    findButton().trigger('click');

    expect(jumpFn).toHaveBeenCalledWith(fromDiscussionId);
  });

  it('sends the correct tracking event when clicked', () => {
    wrapper.find({ ref: 'gl-button' }).trigger('click');

    expect(trackingSpy).toHaveBeenCalledWith('_category_', 'click_button', {
      label: 'mr_next_unresolved_thread',
      property: 'click_next_unresolved_thread',
    });
  });
});
