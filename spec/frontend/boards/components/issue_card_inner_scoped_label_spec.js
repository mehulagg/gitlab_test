<<<<<<< HEAD
import { GlLink } from '@gitlab/ui';
=======
import Vue from 'vue';
>>>>>>> Update labels in Vue with GlLabel component
import { shallowMount } from '@vue/test-utils';
import IssueCardInnerScopedLabel from '~/boards/components/issue_card_inner_scoped_label.vue';
import defaultStore from '~/boards/stores';
import { GlLabel } from '@gitlab/ui';

describe('IssueCardInnerScopedLabel Component', () => {
  let wrapper;
  const Component = Vue.extend(IssueCardInnerScopedLabel);
  const propsData = {
    label: { title: 'Foo::Bar', description: 'Some Random Description', color: '#000000' },
    scopedLabelsDocumentationLink: '/docs-link',
  };

  const createComponent = (props = {}, store = defaultStore) => {
    wrapper = shallowMount(Component, {
      store,
      propsData: { ...props },
    });
  };

  beforeEach(() => {
    createComponent(propsData);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render label with proper props', () => {
    expect(wrapper.findAll(GlLabel).length).toBe(1);
    const label = wrapper.find(GlLabel);
    expect(label.props('title')).toEqual('Foo::Bar');
    expect(label.props('description')).toEqual('Some Random Description');
    expect(label.props('scopedLabelsDocumentationLink')).toEqual('/docs-link');
    expect(label.props('scoped')).toEqual(true);
    expect(label.props('backgroundColor')).toEqual('#000000');
  });
});
