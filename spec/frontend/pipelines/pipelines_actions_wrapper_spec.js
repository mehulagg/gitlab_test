import { shallowMount } from '@vue/test-utils';
import pipelinesActionsWrapper from '~/pipelines/components/pipelines_actions_wrapper.vue';

describe('Pipelines Actions Wrapper', () => {
  let wrapper;

  const createComponent = mockProps => {
    wrapper = shallowMount(pipelinesActionsWrapper, {
      propsData: mockProps,
      slots: {
        'action-buttons': '<button>Retry</button>',
      },
    });
  };

  const clickToggle = () => {
    wrapper.find('.js-more-actions-toggle').vm.$emit('click');
    return wrapper.vm.$nextTick();
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when using normal version of component', () => {
    beforeEach(() => {
      createComponent({
        showAllWithoutToggle: true,
      });
    });

    it('should render the buttons provided into the slot', () => {
      expect(wrapper.findAll('.js-pipelines-actions-wrapper button').length).toBe(1);
    });

    it('should not render the actions toggle', () => {
      expect(wrapper.contains('.js-actions-toggle')).toBe(false);
    });
  });

  describe('when using the compact version of the component', () => {
    beforeEach(() => {
      createComponent({
        showAllWithoutToggle: false,
      });
    });

    it('should not render the buttons by default', () => {
      expect(wrapper.vm.expanded).toBe(false);
      expect(wrapper.findAll('.js-pipelines-actions-wrapper button').length).toBe(0);
    });

    it('should render the actions toggle', () => {
      expect(wrapper.contains('.js-more-actions-toggle')).toBe(true);
    });

    it('should show and hide the buttons when the toggle is clicked', () =>
      clickToggle()
        .then(() => {
          expect(wrapper.html()).toContain('<button>Retry</button>');
        })
        .then(clickToggle)
        .then(() => {
          expect(wrapper.html()).not.toContain('<button>Retry</button>');
        }));
  });
});
