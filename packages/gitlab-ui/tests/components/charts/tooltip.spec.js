import { mount } from '@vue/test-utils';
import Tooltip from '../../../components/charts/tooltip/tooltip.vue';

describe('chart tooltip component', () => {
  const title = 'mock-title';
  const info = {
    0: 10,
    1: 'second-mock-value',
  };
  let wrapper;

  beforeEach(() => {
    wrapper = mount(Tooltip, {
      propsData: {
        title,
        info,
      },
    });
  });

  afterEach(() => wrapper.destroy());

  it('renders tooltip title', () => {
    expect(wrapper.find('.js-header').text()).toBe(title);
  });

  it('renders each attribute and value in info', () => {
    const values = wrapper.findAll('.js-body-value');

    Object.keys(info).forEach(key => {
      const text = values.at(key).text();

      expect(text).toContain(key);
      expect(text).toContain(info[key]);
    });
  });
});
