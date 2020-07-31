import Vue from 'vue';
import mountComponent from 'helpers/vue_mount_component_helper';
import toolbar from '~/vue_shared/components/markdown/toolbar.vue';

describe('toolbar', () => {
  let vm;
  const Toolbar = Vue.extend(toolbar);
  const props = {
    markdownDocsPath: '',
  };

  afterEach(() => {
    vm.$destroy();
  });

  describe('user can attach file', () => {
    beforeEach(() => {
      vm = mountComponent(Toolbar, props);
    });

    it('should render uploading-container', () => {
      expect(vm.$el.querySelector('.uploading-container')).not.toBeNull();
    });
  });

  describe('user cannot attach file', () => {
    beforeEach(() => {
      vm = mountComponent(Toolbar, { ...props, canAttachFile: false });
    });

    it('should not render uploading-container', () => {
      expect(vm.$el.querySelector('.uploading-container')).toBeNull();
    });
  });

  it('renders suggestion template', () => {
    vm = mountComponent(Toolbar, { ...props, canSuggest: true });

    expect(vm.$el.querySelector('[data-testid="suggestBtn"]').getAttribute('data-md-tag')).toEqual(
      '```suggestion:-0+0\n{text}\n```',
    );
  });

  it('does not render suggestion button if `canSuggest` is set to false', () => {
    vm = mountComponent(Toolbar, { ...props, canSuggest: false });

    expect(vm.$el.querySelector('[data-testid="suggestBtn"]')).toBe(null);
  });
});
