import Vue from 'vue';
import { mount } from '@vue/test-utils';
import Icon from '~/vue_shared/components/icon.vue';

describe('Sprite Icon Component', function() {
  describe('Initialization', function() {
    let icon;

    const svg = () => icon.find('svg').element;

    beforeEach(function() {
      const IconComponent = Vue.extend({
        components: { Icon },
        template: `
          <div>
            <Icon v-bind="$attrs" v-on="$listeners" />
          </div>
        `
      });

      icon = mount(IconComponent, {
        propsData: {
          name: 'commit',
          size: 32,
        },
      });
    });

    afterEach(() => {
      icon.destroy();
    });

    it('should return a defined Vue component', function() {
      expect(svg()).toBeDefined();
    });

    it('should have <svg> as a child element', function() {
      expect(svg().tagName).toBe('svg');
    });

    it('should have <use> as a child element with the correct href', function() {
      expect(svg().firstChild.tagName).toBe('use');
      expect(svg().firstChild.getAttribute('xlink:href')).toBe(`${gon.sprite_icons}#commit`);
    });

    it('should properly compute iconSizeClass', function() {
      expect(svg().classList).toContain('s32');
    });

    it('`name` validator should return false for non existing icons', () => {
      expect(Icon.props.name.validator('non_existing_icon_sprite')).toBe(false);
    });

    it('`name` validator should return false for existing icons', () => {
      expect(Icon.props.name.validator('commit')).toBe(true);
    });
  });

  it('should call registered listeners when they are triggered', () => {
    const clickHandler = jasmine.createSpy('clickHandler');
    const wrapper = mount(Icon, {
      propsData: { name: 'commit' },
      listeners: { click: clickHandler },
    });

    wrapper.find('svg').trigger('click');

    expect(clickHandler).toHaveBeenCalled();
  });
});
