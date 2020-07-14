import ClusterCpu from '~/clusters_list/components/cluster_cpu.vue';
import ClusterStore from '~/clusters_list/store';
import { shallowMount } from '@vue/test-utils';
import { GlSprintf } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';

describe('ClusterCpu', () => {
  let captureException;
  let store;
  let wrapper;

  const createWrapper = propsData => {
    store = ClusterStore({});
    wrapper = shallowMount(ClusterCpu, { store, stubs: { GlSprintf }, propsData });
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
        { status: { allocatable: { cpu: '1930m' } } },
        { status: { allocatable: { cpu: '1930m' } } },
      ];

      return createWrapper({ nodes });
    });

    it('does not diplay cpu usage', () => {
      expect(wrapper.text()).toBe('');
    });

    it('does not report a senty error', () => {
      expect(captureException).toHaveBeenCalledTimes(0);
    });
  });

  describe('when cpu quantity is unknown', () => {
    beforeEach(() => {
      const nodes = [
        {
          status: { allocatable: { cpu: '1missingCpuUnit' } },
          usage: { cpu: '1missingCpuUnit' },
        },
      ];

      return createWrapper({ nodes });
    });

    it('does not display cpu usage', () => {
      expect(wrapper.text()).toBe('');
    });

    it('notifies Sentry about Memory missing quantity types', () => {
      const missingCpuTypeError = new Error('UnknownK8sQuantity:1missingCpuUnit');

      expect(captureException).toHaveBeenCalledTimes(1);
      expect(captureException).toHaveBeenCalledWith(missingCpuTypeError);
    });
  });

  describe('when cpu quantity is valid', () => {
    beforeEach(() => {
      const nodes = [
        {
          status: { allocatable: { cpu: '1930m' } },
          usage: { cpu: '246155922n' },
        },
        {
          status: { allocatable: { cpu: '1940m' } },
          usage: { cpu: '307051934n' },
        },
      ];

      return createWrapper({ nodes });
    });

    it('displays cpu usage', () => {
      expect(wrapper.text()).toBe('3.87 (86% free)');
    });

    it('does not report a senty error', () => {
      expect(captureException).toHaveBeenCalledTimes(0);
    });
  });
});
