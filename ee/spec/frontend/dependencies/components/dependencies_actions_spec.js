import { createLocalVue, shallowMount } from '@vue/test-utils';
import createStore from 'ee/dependencies/store';
import DependenciesActions from 'ee/dependencies/components/dependencies_actions.vue';

describe('DependenciesActions component', () => {
  test.todo('needs testing');

  let wrapper;

  const factory = (props = {}) => {
    const localVue = createLocalVue();

    wrapper = shallowMount(localVue.extend(DependenciesActions), {
      localVue,
      store: createStore(),
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

  it.todo('dispatches the setSortField action on clicking item in dropdown');

  it.todo('dispatches the setSortOrder action on clicking item in dropdown');

  it.todo('has a button to export the dependency list');
});
