import Vue from 'vue';
import component from 'ee/pages/subscriptions/new/components/checkout/progress_bar.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Progress Bar', () => {
  let vm;
  let props;
  const Component = Vue.extend(component);

  beforeEach(() => {
    props = { step: 2 };
    vm = mountComponent(Component, props);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('current', () => {
    it('step 1 is not current', () => {
      expect(vm.$el.querySelector('.bar div:nth-child(1)')).not.toHaveClass('current');
    });

    it('step 2 is current', () => {
      expect(vm.$el.querySelector('.bar div:nth-child(2)')).toHaveClass('current');
    });
  });

  describe('finished', () => {
    it('step 1 is finished', () => {
      expect(vm.$el.querySelector('.bar div:nth-child(1)')).toHaveClass('finished');
    });

    it('step 2 is not finished', () => {
      expect(vm.$el.querySelector('.bar div:nth-child(2)')).not.toHaveClass('finished');
    });
  });
});
