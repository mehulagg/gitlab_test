import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IssueCardInnerScopedLabel from '~/boards/components/issue_card_inner_scoped_label.vue';

describe('IssueCardInnerScopedLabel Component', () => {
  let vm;
  const Component = Vue.extend(IssueCardInnerScopedLabel);
  const props = {
    label: { title: 'Foo::Bar', description: 'Some Random Description', color: '#000000' },
    labelStyle: { background: 'white', color: 'black' },
    scopedLabelsDocumentationLink: '/docs-link',
  };
  const createComponent = () => mountComponent(Component, { ...props });

  beforeEach(() => {
    wrapper = shallowMount(IssueCardInnerScopedLabel, {
      propsData: {
        label: { title: 'Foo::Bar', description: 'Some Random Description' },
        labelStyle: { background: 'white', color: 'black' },
        scopedLabelsDocumentationLink: '/docs-link',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('should render label title', () => {
    // expect(vm.$el.find('.gl-label-text').textContent.trim()).toEqual('Foo::Bar');
    expect(vm.$el.querySelector('.gl-label-text:first-child').textContent.trim()).toContain('Foo');
    expect(vm.$el.querySelector('.gl-label-text:last-child').textContent.trim()).toContain('Bar');
  });

  it('should render question mark symbol', () => {
    expect(vm.$el.querySelector('.gl-icon')).not.toBeNull();
  });

  it('should render the docs link', () => {
    expect(vm.$el.querySelector('a.gl-link.gl-label-icon').href).toContain(
      props.scopedLabelsDocumentationLink,
    );
  });
});
