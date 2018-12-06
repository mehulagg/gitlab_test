import { shallowMount } from '@vue/test-utils';
import EmptyState from '../../../components/regions/empty_state/empty_state.vue';
import Button from '../../../components/base/button/button.vue';

describe('empty state component', () => {
  let component;
  const props = {
    title: 'Empty State Title',
    description: 'Empty state description.',
    svgPath: 'https://www.example.com/test.jpg',
    primaryButtonText: 'Primary Button',
    primaryButtonLink: 'http://example.com/primary',
    secondaryButtonText: 'Secondary Button',
    secondaryButtonLink: 'http://example.com/secondary',
  };

  describe('with no buttons', () => {
    beforeEach(() => {
      component = shallowMount(EmptyState, {
        propsData: {
          title: props.title,
          description: props.description,
          svgPath: props.svgPath,
        },
      });
    });

    it('should render the title', () => {
      const title = component.find('h4');
      expect(title.text()).toEqual(props.title);
    });

    it('should render the description', () => {
      const description = component.find('p');
      expect(description.text()).toEqual(props.description);
    });

    it('should pass through the SVG path', () => {
      const image = component.find('img');
      expect(image.attributes().src).toEqual(props.svgPath);
    });
  });

  describe('with a primary button', () => {
    beforeEach(() => {
      component = shallowMount(EmptyState, {
        propsData: {
          title: props.title,
          svgPath: props.svgPath,
          primaryButtonLink: props.primaryButtonLink,
          primaryButtonText: props.primaryButtonText,
        },
      });
    });

    it('should only render one button', () => {
      const buttons = component.findAll(Button);
      expect(buttons).toHaveLength(1);
    });

    it('should render the primary button', () => {
      const button = component.find(Button);
      expect(button.attributes().href).toEqual(props.primaryButtonLink);
    });
  });

  describe('with a primary and secondary button', () => {
    beforeEach(() => {
      component = shallowMount(EmptyState, {
        propsData: {
          title: props.title,
          svgPath: props.svgPath,
          primaryButtonLink: props.primaryButtonLink,
          primaryButtonText: props.primaryButtonText,
          secondaryButtonLink: props.secondaryButtonLink,
          secondaryButtonText: props.secondaryButtonText,
        },
      });
    });

    it('should render two buttons', () => {
      const buttons = component.findAll(Button);
      expect(buttons).toHaveLength(2);
    });

    it('should render the primary button', () => {
      const button = component.find(Button);
      expect(button.attributes().href).toEqual(props.primaryButtonLink);
    });

    it('should also render the secondary button', () => {
      const button = component.findAll(Button).at(1);
      expect(button.attributes().href).toEqual(props.secondaryButtonLink);
    });
  });
});
