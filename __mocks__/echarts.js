/* eslint-env jest */

process.env.BOOTSTRAP_VUE_NO_WARN = true;

const echarts = jest.genMockFromModule('../node_modules/echarts');

const mockInstance = {
  on: jest.fn(),
  off: jest.fn(),
  getOption: jest.fn(() => ({
    color: ['#c23531', '#2f4554', '#61a0a8'],
    lineStyle: {},
    series: [],
  })),
  setOption: jest.fn(),
  resize: jest.fn(),
  getDom: () => ({
    getAttribute: jest.fn(),
    removeEventListener: jest.fn(),
    addEventListener: jest.fn(),
    _isDestroyed: true,
  }),
};

echarts.init.mockReturnValue(mockInstance);
echarts.getInstanceByDom.mockReturnValue(mockInstance);

export default echarts;
