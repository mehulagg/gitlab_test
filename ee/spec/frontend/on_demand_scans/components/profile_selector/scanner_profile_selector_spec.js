import { merge } from 'lodash';
import { mount, shallowMount } from '@vue/test-utils';
import OnDemandScansScannerProfileSelector from 'ee/on_demand_scans/components/profile_selector/scanner_profile_selector.vue';
import { scannerProfiles } from '../../mock_data';

describe('OnDemandScansScannerProfileSelector', () => {
  let wrapper;

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      OnDemandScansScannerProfileSelector,
      merge(
        {},
        {
          propsData: {
            profiles: [],
          },
        },
        options,
      ),
    );
  };
  const createFullComponent = wrapperFactory(mount);

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders properly with profiles', () => {
    createFullComponent({
      propsData: { profiles: scannerProfiles },
    });

    expect(wrapper.html()).toMatchSnapshot();
  });

  it('renders properly without profiles', () => {
    createFullComponent();

    expect(wrapper.html()).toMatchSnapshot();
  });
});
