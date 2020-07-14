import * as utils from '~/clusters_list/utils';

describe('ClusterList utilities', () => {
  describe('calculatePercentage', () => {
    it('calculates and rounds percentage used', () => {
      expect(utils.calculatePercentage(100, 9.9999)).toBe(90);
    });
  });

  describe('sumNodeCpuAndUsage', () => {
    it('sums cpu when value is a number', () => {
      const node = {
        status: { allocatable: { cpu: '128974848' } },
        usage: { cpu: '128974848' },
      };

      expect(utils.sumNodeCpuAndUsage({ allocated: 20, used: 0 }, node)).toEqual({
        allocated: 128974868,
        used: 128974848,
      });
    });

    it('sums cpu when value is a base 2 exponent', () => {
      const node = {
        status: { allocatable: { cpu: '123Mi' } },
        usage: { cpu: '123Mi' },
      };

      expect(utils.sumNodeCpuAndUsage({ allocated: 20, used: 0 }, node)).toEqual({
        allocated: 128974868,
        used: 128974848,
      });
    });

    it('sums cpu when value includes scientific notation', () => {
      const node = {
        status: { allocatable: { cpu: '129e6' } },
        usage: { cpu: '129e6' },
      };

      expect(utils.sumNodeCpuAndUsage({ allocated: 20, used: 0 }, node)).toEqual({
        allocated: 129000020,
        used: 129000000,
      });
    });

    it('sums cpu when value is a base 10 exponent', () => {
      const node = {
        status: { allocatable: { cpu: '129M' } },
        usage: { cpu: '129M' },
      };

      expect(utils.sumNodeCpuAndUsage({ allocated: 20, used: 0 }, node)).toEqual({
        allocated: 129000020,
        used: 129000000,
      });
    });

    it('throws an error when k8s type is unknown', () => {
      const node = {
        status: { allocatable: { cpu: '1missingCpuUnit' } },
        usage: { cpu: '1missingCpuUnit' },
      };

      expect(() => {
        utils.sumNodeCpuAndUsage({ allocated: 20, used: 0 }, node);
      }).toThrow('UnknownK8sQuantity:1missingCpuUnit');
    });

    it('calcuates to 0 when cpu is missing', () => {
      const node = {
        status: { allocatable: {} },
        usage: {},
      };

      expect(utils.sumNodeCpuAndUsage({ allocated: 20, used: 0 }, node)).toEqual({
        allocated: 20,
        used: 0,
      });
    });
  });

  describe('sumNodeMemoryAndUsage', () => {
    it('sums memory and converts to GB', () => {
      const node = {
        status: { allocatable: { memory: '123Mi' } },
        usage: { memory: '123Mi' },
      };

      expect(utils.sumNodeMemoryAndUsage({ allocated: 1, used: 10 }, node)).toEqual({
        allocated: 1.128974848,
        used: 10.128974848,
      });
    });

    it('calcuates to 0 when memory is missing', () => {
      const node = {
        status: { allocatable: {} },
        usage: {},
      };

      expect(utils.sumNodeCpuAndUsage({ allocated: 1, used: 10 }, node)).toEqual({
        allocated: 1,
        used: 10,
      });
    });
  });
});
