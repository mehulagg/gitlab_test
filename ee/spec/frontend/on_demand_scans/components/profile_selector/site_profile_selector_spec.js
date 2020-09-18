import { merge } from 'lodash';
import { mount, shallowMount } from '@vue/test-utils';
import OnDemandScansSiteProfileSelector from 'ee/on_demand_scans/components/profile_selector/site_profile_selector.vue';
import { siteProfiles } from '../../mock_data';

describe('OnDemandScansSiteProfileSelector', () => {
  let wrapper;

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      OnDemandScansSiteProfileSelector,
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
      propsData: { profiles: siteProfiles },
    });

    expect(wrapper.html()).toMatchSnapshot();
  });

  it('renders properly without profiles', () => {
    createFullComponent();

    expect(wrapper.html()).toMatchSnapshot();
  });
});
