import { shallowMount } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import CodeCoverage from '~/pages/projects/graphs/components/CodeCoverage.vue';

describe('Code Coverage', () => {
  let wrapper;

  const props = {
    languages: [
      {
        color: '#2c3e50',
        highlight: '#2c3e50',
        label: 'Vue',
        value: 71.62,
      },
      {
        color: '#e34c26',
        highlight: '#e34c26',
        label: 'HTML',
        value: 17.33,
      },
      {
        color: '#f1e05a',
        highlight: '#f1e05a',
        label: 'JavaScript',
        value: 11.05,
      },
    ],
  };

  const createComponent = (props) => {
    wrapper = shallowMount(CodeCoverage, {
      propsData: {
        ...props,
      },
    });
  };

  beforeEach(() => {
    createComponent(props);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the dropdown with all languages', () => {
    expect(wrapper.contains(GlDropdown)).toBeDefined();
    expect(wrapper.findAll(GlDropdownItem)).toHaveLength(3);
  });

  it('renders the area chart', () => {
    expect(wrapper.contains(GlAreaChart)).toBeDefined();
  });
  
  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

});
