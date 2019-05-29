import { createLocalVue, shallowMount } from '@vue/test-utils';
import { TEST_HOST } from 'helpers/test_constants';
import createStore from 'ee/dependencies/store';
import DependenciesApp from 'ee/dependencies/components/app.vue';

describe('DependenciesApp component', () => {
  test.todo('needs testing');

  let store;
  let wrapper;

  const basicAppProps = {
    endpoint: '/foo',
    emptyStateSvgPath: '/bar.svg',
    documentationPath: TEST_HOST,
  };

  const factory = (props = basicAppProps) => {
    const localVue = createLocalVue();

    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(localVue.extend(DependenciesApp), {
      localVue,
      store,
      sync: false,
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('dispatches the correct initial actions', () => {
    factory();
    expect(store.calls).toHaveLength(2);
  });

  // it('matches the snapshot', () => {
  //   factory();
  //   expect(wrapper.element).toMatchSnapshot();
  // });

  test.todo('renders dependency list normally');
  test.todo('renders empty state');
  test.todo('renders job failure');
  test.todo('renders incomplete job');
  test.todo('renders error');
});
