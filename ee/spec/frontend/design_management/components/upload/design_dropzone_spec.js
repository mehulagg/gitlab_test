import { shallowMount } from '@vue/test-utils';
import DesignDropzone from 'ee/design_management/components/upload/design_dropzone.vue';

describe('Design management dropzone component', () => {
  let wrapper;

  function createComponent({ slots = {} } = {}) {
    wrapper = shallowMount(DesignDropzone, {
      slots,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when slot provided', () => {
    it('renders dropzone with slot content', () => {
      createComponent({
        slots: {
          default: ['<div>dropzone slot</div>'],
        },
      });

      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('when no slot provided', () => {
    it('renders default dropzone card', () => {
      createComponent();

      expect(wrapper.element).toMatchSnapshot();
    });
  });
});
