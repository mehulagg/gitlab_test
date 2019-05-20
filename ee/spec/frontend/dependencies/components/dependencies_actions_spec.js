import { createLocalVue, mount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import createStore from 'ee/dependencies/store';
import DependenciesActions from 'ee/dependencies/components/dependencies_actions.vue';

describe('DependenciesActions component', () => {
  test.todo('needs testing');

  let store;
  let wrapper;

  const factory = (props = {}) => {
    const localVue = createLocalVue();

    store = createStore();
    jest.spyOn(store, 'dispatch');
    wrapper = mount(localVue.extend(DependenciesActions), {
      localVue,
      store,
      sync: false,
    });
  };

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('dispatches the setSortField action on clicking item in dropdown', () => {
    const item = wrapper.find(GlDropdownItem);
    item.trigger('click');
    expect(store.dispatch).toHaveBeenCalledWith('setSortField', expect.any(String));
  });

  it.todo('dispatches the setSortOrder action on clicking item in dropdown');

  it.todo('has a button to export the dependency list');
});
