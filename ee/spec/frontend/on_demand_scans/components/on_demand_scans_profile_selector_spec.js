import { merge } from 'lodash';
import { mount, shallowMount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import OnDemandScansProfileSelector from 'ee/on_demand_scans/components/on_demand_scans_profile_selector.vue';

describe('OnDemandScansProfileSelector', () => {
  let wrapper;

  const profiles = [
    { id: 489, profileName: 'An awesome profile', spiderTimeout: 5, targetTimeout: 10 },
    { id: 567, profileName: 'An even better profile', spiderTimeout: 20, targetTimeout: 150 },
  ];

  const defaultProps = {
    settings: {
      libraryPath: '/path/to/profiles/library',
      newProfilePath: '/path/to/new/profile/form',
      selectedProfileDropdownLabel: () => 'Formatted profile name',
      i18n: {
        title: 'Section title',
        formGroupLabel: 'Use existing scanner profile',
        noProfilesText: 'No profile yet',
        newProfileLabel: 'Create a new profile',
      },
      summary: [
        [['Scan mode', () => 'Passive']],
        [
          ['Spider timeout', profile => profile.spiderTimeout],
          ['Target timeout', profile => profile.targetTimeout],
        ],
      ],
    },
    profiles: [],
  };

  const findByTestId = testId => wrapper.find(`[data-testid="${testId}"]`);
  const findProfilesLibraryPathLink = () => findByTestId('manage-profiles-link');
  const findProfilesDropdown = () => findByTestId('profiles-dropdown');
  const findCreateNewProfileLink = () => findByTestId('create-profile-link');
  const findSelectedProfileSummary = () => findByTestId('selected-profile-summary');

  const selectFirstProfile = async () => {
    await findProfilesDropdown()
      .find(GlDropdownItem)
      .vm.$emit('click');
  };

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      OnDemandScansProfileSelector,
      merge(
        {},
        {
          propsData: defaultProps,
        },
        options,
      ),
    );
  };
  // const createComponent = wrapperFactory();
  const createFullComponent = wrapperFactory(mount);

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows section title and link to profiles library', () => {
    createFullComponent();

    expect(wrapper.text()).toContain('Section title');
  });

  describe('when there are no profiles yet', () => {
    beforeEach(() => {
      createFullComponent();
    });

    it('disables the link to profiles library', () => {
      expect(findProfilesLibraryPathLink().props('disabled')).toBe(true);
    });

    it('shows a help text and a link to create a new profile', () => {
      const link = findCreateNewProfileLink();

      expect(wrapper.text()).toContain('No profile yet');
      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe('/path/to/new/profile/form');
      expect(link.text()).toBe('Create a new profile');
    });
  });

  describe('when there are profiles', () => {
    beforeEach(() => {
      createFullComponent({
        propsData: { profiles },
      });
    });

    it('enables link to profiles management', () => {
      expect(findProfilesLibraryPathLink().props('disabled')).toBe(false);
      expect(findProfilesLibraryPathLink().attributes('href')).toBe('/path/to/profiles/library');
    });

    it('shows a dropdown containing the profiles', () => {
      const dropdown = findProfilesDropdown();

      expect(wrapper.text()).toContain('Use existing scanner profile');
      expect(dropdown.exists()).toBe(true);
      expect(dropdown.element.children).toHaveLength(profiles.length);
    });

    describe('when a profile is selected', () => {
      beforeEach(async () => {
        await selectFirstProfile();
      });

      it('when a profile is selected, its summary is displayed below the dropdown', () => {
        const summary = findSelectedProfileSummary();

        expect(summary.exists()).toBe(true);

        const summaryText = summary.text();
        expect(summaryText).toContain('Passive');
        expect(summaryText).toContain(profiles[0].spiderTimeout);
        expect(summaryText).toContain(profiles[0].targetTimeout);
      });

      it('emits the set-profile event', () => {
        expect(wrapper.emitted('set-profile')).toEqual([[489]]);
      });
    });
  });
});
