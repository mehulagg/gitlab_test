import { createLocalVue, shallowMount } from '@vue/test-utils';
import DependenciesTableRow from 'ee/dependencies/components/dependencies_table_row.vue';

describe('DependenciesTableRow component', () => {
  let wrapper;

  const factory = (props = {}) => {
    const localVue = createLocalVue();

    wrapper = shallowMount(localVue.extend(DependenciesTableRow), {
      localVue,
      sync: false,
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when passed no props', () => {
    beforeEach(() => {
      factory();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('when loading', () => {
    beforeEach(() => {
      factory({
        isLoading: true,
      });
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('when a dependency is loaded', () => {
    beforeEach(() => {
      factory({
        isLoading: false,
        dependency: {
          name: 'left-pad',
          version: '0.0.3',
          type: 'npm',
          location: {
            blob_path: 'yarn.lock',
          },
        },
      });
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });
});
