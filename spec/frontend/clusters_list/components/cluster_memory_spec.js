import ClusterMemory from '~/clusters_list/components/cluster_memory.vue';
import ClusterStore from '~/clusters_list/store';
import { shallowMount } from '@vue/test-utils';
import { GlSprintf } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';

describe('ClusterMemory', () => {
  let captureException;
  let store;
  let wrapper;

  const createWrapper = propsData => {
    store = ClusterStore({});
    wrapper = shallowMount(ClusterMemory, { store, stubs: { GlSprintf }, propsData });
    return wrapper.vm.$nextTick();
  };

  beforeEach(() => {
    captureException = jest.spyOn(Sentry, 'captureException');
  });

  afterEach(() => {
    wrapper.destroy();
    captureException.mockRestore();
  });

  describe('when metrics data is missing', () => {
    beforeEach(() => {
      const nodes = [
        { status: { allocatable: { memory: '5777156Ki' } } },
        { status: { allocatable: { memory: '5777156Ki' } } },
      ];

      return createWrapper({ nodes });
    });

    it('does not diplay memory usage', () => {
      expect(wrapper.text()).toBe('');
    });

    it('does not report a senty error', () => {
      expect(captureException).toHaveBeenCalledTimes(0);
    });
  });

  describe('when memory quantity is unknown', () => {
    beforeEach(() => {
      const nodes = [
        {
          status: { allocatable: { memory: '1missingMemoryUnit' } },
          usage: { memory: '1missingMemoryUnit' },
        },
      ];

      return createWrapper({ nodes });
    });

    it('does not display memory usage', () => {
      expect(wrapper.text()).toBe('');
    });

    it('notifies Sentry about Memory missing quantity types', () => {
      const missingMemoryTypeError = new Error('UnknownK8sQuantity:1missingMemoryUnit');

      expect(captureException).toHaveBeenCalledTimes(1);
      expect(captureException).toHaveBeenCalledWith(missingMemoryTypeError);
    });
  });

  describe('when memory quantity is valid', () => {
    beforeEach(() => {
      const nodes = [
        {
          status: { allocatable: { memory: '5777156Ki' } },
          usage: { memory: '1255212Ki' },
        },
        {
          status: { allocatable: { memory: '6777156Ki' } },
          usage: { memory: '1379136Ki' },
        },
      ];

      return createWrapper({ nodes });
    });

    it('displays memory usage', () => {
      expect(wrapper.text()).toBe('12.86 (79% free)');
    });

    it('does not report a senty error', () => {
      expect(captureException).toHaveBeenCalledTimes(0);
    });
  });
});
