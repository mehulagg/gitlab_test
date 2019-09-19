import toast from '~/vue_shared/plugins/global_toast';
import Vue from 'vue';

describe('Global toast', () => {
  let spyFunc;

  beforeEach(() => {
    spyFunc = jest.spyOn(Vue.toasted, 'show').mockImplementation(() => {});
  });

  afterEach(() => {
    spyFunc.mockRestore();
  });

  it('should call Vue toasted', () => {
    const arg1 = 'TestMessage';
    const arg2 = { className: 'foo' };

    toast(arg1, arg2);

    expect(Vue.toasted.show).toHaveBeenCalledTimes(1);
  });
});
