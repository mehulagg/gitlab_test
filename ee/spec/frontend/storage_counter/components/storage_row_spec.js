import { shallowMount } from '@vue/test-utils';
import StorageRow from 'ee/storage_counter/components/storage_row.vue';
import Icon from '~/vue_shared/components/icon.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';

let wrapper;
const data = {
  name: 'LFS Package',
  value: 1293346,
  icon: 'doc-image',
  description: 'description',
};

function factory({ name, value, icon, description }) {
  wrapper = shallowMount(StorageRow, {
    propsData: {
      name,
      value,
      icon,
      description,
    },
  });
}

describe('Storage Counter row component', () => {
  beforeEach(() => {
    factory(data);
  });

  it('renders provided name', () => {
    expect(wrapper.text()).toContain(data.name);
  });

  it('renders formatted value', () => {
    expect(wrapper.text()).toContain(numberToHumanSize(data.value));
  });

  it('renders description', () => {
    expect(wrapper.text()).toContain(data.description);
  });

  it('renders icon', () => {
    const icon = wrapper.find(Icon);

    expect(icon.exists()).toBe(true);
    expect(icon.props()).toEqual(
      expect.objectContaining({
        name: data.icon,
      }),
    );
  });
});
