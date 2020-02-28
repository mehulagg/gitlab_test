import { shallowMount } from '@vue/test-utils';

import settingsPanel from '~/pages/projects/shared/permissions/components/settings_panel.vue';
import {
  featureAccessLevel,
  visibilityLevelDescriptions,
  visibilityOptions,
} from '~/pages/projects/shared/permissions/constants';

const defaultSettings = {
  currentSettings: {
    visibilityLevel: 10,
    requestAccessEnabled: true,
    issuesAccessLevel: 20,
    repositoryAccessLevel: 20,
    forkingAccessLevel: 20,
    mergeRequestsAccessLevel: 20,
    buildsAccessLevel: 20,
    wikiAccessLevel: 20,
    snippetsAccessLevel: 20,
    pagesAccessLevel: 10,
    containerRegistryEnabled: true,
    lfsEnabled: true,
    emailsDisabled: false,
    packagesEnabled: true,
  },
  canDisableEmails: true,
  canChangeVisibilityLevel: true,
  allowedVisibilityOptions: [0, 10, 20],
  visibilityHelpPath: '/help/public_access/public_access',
  registryAvailable: false,
  registryHelpPath: '/help/user/packages/container_registry/index',
  lfsAvailable: true,
  lfsHelpPath: '/help/workflow/lfs/manage_large_binaries_with_git_lfs',
  pagesAvailable: true,
  pagesAccessControlEnabled: false,
  pagesAccessControlForced: false,
  pagesHelpPath: '/help/user/project/pages/introduction#gitlab-pages-access-control-core',
  packagesAvailable: false,
  packagesHelpPath: '/help/user/packages/index',
};

describe('Settings Panel', () => {
  describe('Project Visibility', () => {
    it('should set the project visibility help path', () => {
      const wrapper = shallowMount(settingsPanel, { propsData: defaultSettings });

      expect(wrapper.find({ ref: 'project-visibility-settings' }).props().helpPath).toBe(
        defaultSettings.visibilityHelpPath,
      );
    });

    it('should not disable the visibility level dropdown', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: { ...defaultSettings, canChangeVisibilityLevel: true },
      });

      expect(
        wrapper.find('[name="project[visibility_level]"]').attributes().disabled,
      ).toBeUndefined();
    });

    it('should disable the visibility level dropdown', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: { ...defaultSettings, canChangeVisibilityLevel: false },
      });

      expect(wrapper.find('[name="project[visibility_level]"]').attributes().disabled).toBe(
        'disabled',
      );
    });

    it.each`
      option                        | allowedOptions                                                                       | disabled
      ${visibilityOptions.PRIVATE}  | ${[visibilityOptions.PRIVATE, visibilityOptions.INTERNAL, visibilityOptions.PUBLIC]} | ${false}
      ${visibilityOptions.PRIVATE}  | ${[visibilityOptions.INTERNAL, visibilityOptions.PUBLIC]}                            | ${true}
      ${visibilityOptions.INTERNAL} | ${[visibilityOptions.PRIVATE, visibilityOptions.INTERNAL, visibilityOptions.PUBLIC]} | ${false}
      ${visibilityOptions.INTERNAL} | ${[visibilityOptions.PRIVATE, visibilityOptions.PUBLIC]}                             | ${true}
      ${visibilityOptions.PUBLIC}   | ${[visibilityOptions.PRIVATE, visibilityOptions.INTERNAL, visibilityOptions.PUBLIC]} | ${false}
      ${visibilityOptions.PUBLIC}   | ${[visibilityOptions.PRIVATE, visibilityOptions.INTERNAL]}                           | ${true}
    `(
      'sets disabled to $disabled for the visibility option $option when given $allowedOptions',
      ({ option, allowedOptions, disabled }) => {
        const wrapper = shallowMount(settingsPanel, {
          propsData: { ...defaultSettings, allowedVisibilityOptions: allowedOptions },
        });
        const attributeValue = wrapper
          .find(`[name="project[visibility_level]"] option[value="${option}"]`)
          .attributes().disabled;

        if (disabled) {
          expect(attributeValue).toBe('disabled');
        } else {
          expect(attributeValue).toBeUndefined();
        }
      },
    );

    it('should set the visibility level description based upon the selected visibility level', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: { ...defaultSettings },
      });

      wrapper.find('[name="project[visibility_level]"]').setValue(visibilityOptions.INTERNAL);

      expect(wrapper.find({ ref: 'project-visibility-settings' }).text()).toContain(
        visibilityLevelDescriptions[visibilityOptions.INTERNAL],
      );
    });

    it('should show the request access checkbox if the visibility level is not private', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            visibilityLevel: visibilityOptions.INTERNAL,
          },
        },
      });

      expect(wrapper.find('[name="project[request_access_enabled]"]').exists()).toBe(true);
    });

    it('should not show the request access checkbox if the visibility level is private', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            visibilityLevel: visibilityOptions.PRIVATE,
          },
        },
      });

      expect(wrapper.find('[name="project[request_access_enabled]"]').exists()).toBe(false);
    });
  });

  describe('Repository', () => {
    it('should set the repository help text when the visibility level is set to private', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            visibilityLevel: visibilityOptions.PRIVATE,
          },
        },
      });

      expect(wrapper.find({ ref: 'repository-settings' }).props().helpText).toEqual(
        'View and edit files in this project',
      );
    });

    it('should set the repository help text with a read access warning when the visibility level is set to non-private', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            visibilityLevel: visibilityOptions.PUBLIC,
          },
        },
      });

      expect(wrapper.find({ ref: 'repository-settings' }).props().helpText).toEqual(
        'View and edit files in this project. Non-project members will only have read access',
      );
    });
  });

  describe('Merge requests', () => {
    it('should enable the merge requests access level input when the repository is enabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.EVERYONE,
          },
        },
      });

      expect(
        wrapper
          .find('[name="project[project_feature_attributes][merge_requests_access_level]"]')
          .props().disabledInput,
      ).toEqual(false);
    });

    it('should disable the merge requests access level input when the repository is disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.NOT_ENABLED,
          },
        },
      });

      expect(
        wrapper
          .find('[name="project[project_feature_attributes][merge_requests_access_level]"]')
          .props().disabledInput,
      ).toEqual(true);
    });
  });

  describe('Forks', () => {
    it('should enable the forking access level input when the repository is enabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.EVERYONE,
          },
        },
      });

      expect(
        wrapper.find('[name="project[project_feature_attributes][forking_access_level]"]').props()
          .disabledInput,
      ).toEqual(false);
    });

    it('should disable the forking access level input when the repository is disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.NOT_ENABLED,
          },
        },
      });

      expect(
        wrapper.find('[name="project[project_feature_attributes][forking_access_level]"]').props()
          .disabledInput,
      ).toEqual(true);
    });
  });

  describe('Pipelines', () => {
    it('should enable the builds access level input when the repository is enabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.EVERYONE,
          },
        },
      });

      expect(
        wrapper.find('[name="project[project_feature_attributes][builds_access_level]"]').props()
          .disabledInput,
      ).toEqual(false);
    });

    it('should disable the builds access level input when the repository is disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.NOT_ENABLED,
          },
        },
      });

      expect(
        wrapper.find('[name="project[project_feature_attributes][builds_access_level]"]').props()
          .disabledInput,
      ).toEqual(true);
    });
  });

  describe('Container registry', () => {
    it('should show the container registry settings if the registry is available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: true,
        },
      });

      expect(wrapper.find({ ref: 'container-registry-settings' }).exists()).toBe(true);
    });

    it('should hide the container registry settings if the registry is not available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: false,
        },
      });

      expect(wrapper.find({ ref: 'container-registry-settings' }).exists()).toBe(false);
    });

    it('should set the container registry settings help path', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: true,
        },
      });

      expect(wrapper.find({ ref: 'container-registry-settings' }).props().helpPath).toBe(
        defaultSettings.registryHelpPath,
      );
    });

    it('should show the container registry public note if the visibility level is public and the registry is available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            visibilityLevel: visibilityOptions.PUBLIC,
          },
        },
      });

      expect(wrapper.find({ ref: 'container-registry-settings' }).text()).toContain(
        'Note: the container registry is always visible when a project is public',
      );
    });

    it('should hide the container registry public note if the visibility level is private and the registry is available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            visibilityLevel: visibilityOptions.PRIVATE,
          },
        },
      });

      expect(wrapper.find({ ref: 'container-registry-settings' }).text()).not.toContain(
        'Note: the container registry is always visible when a project is public',
      );
    });

    it('should enable the container registry input when the repository is enabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.EVERYONE,
          },
        },
      });

      expect(
        wrapper.find('[name="project[container_registry_enabled]"]').props().disabledInput,
      ).toEqual(false);
    });

    it('should disable the container registry input when the repository is disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          registryAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.NOT_ENABLED,
          },
        },
      });

      expect(
        wrapper.find('[name="project[container_registry_enabled]"]').props().disabledInput,
      ).toEqual(true);
    });
  });

  describe('Git Large File Storage', () => {
    it('should show the LFS settings if LFS is available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          lfsAvailable: true,
        },
      });

      expect(wrapper.find({ ref: 'git-lfs-settings' }).exists()).toEqual(true);
    });

    it('should hide the LFS settings if LFS is not available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          lfsAvailable: false,
        },
      });

      expect(wrapper.find({ ref: 'git-lfs-settings' }).exists()).toEqual(false);
    });

    it('should set the LFS settings help path', () => {
      const wrapper = shallowMount(settingsPanel, { propsData: defaultSettings });

      expect(wrapper.find({ ref: 'git-lfs-settings' }).props().helpPath).toBe(
        defaultSettings.lfsHelpPath,
      );
    });

    it('should enable the LFS input when the repository is enabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          lfsAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.EVERYONE,
          },
        },
      });

      expect(wrapper.find('[name="project[lfs_enabled]"]').props().disabledInput).toEqual(false);
    });

    it('should disable the LFS input when the repository is disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          lfsAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.NOT_ENABLED,
          },
        },
      });

      expect(wrapper.find('[name="project[lfs_enabled]"]').props().disabledInput).toEqual(true);
    });
  });

  describe('Packages', () => {
    it('should show the packages settings if packages are available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          packagesAvailable: true,
        },
      });

      expect(wrapper.find({ ref: 'package-settings' }).exists()).toEqual(true);
    });

    it('should hide the packages settings if packages are not available', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          packagesAvailable: false,
        },
      });

      expect(wrapper.find({ ref: 'package-settings' }).exists()).toEqual(false);
    });

    it('should set the package settings help path', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          packagesAvailable: true,
        },
      });

      expect(wrapper.find({ ref: 'package-settings' }).props().helpPath).toBe(
        defaultSettings.packagesHelpPath,
      );
    });

    it('should enable the packages input when the repository is enabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          packagesAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.EVERYONE,
          },
        },
      });

      expect(wrapper.find('[name="project[packages_enabled]"]').props().disabledInput).toEqual(
        false,
      );
    });

    it('should disable the packages input when the repository is disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          packagesAvailable: true,
          currentSettings: {
            ...defaultSettings.currentSettings,
            repositoryAccessLevel: featureAccessLevel.NOT_ENABLED,
          },
        },
      });

      expect(wrapper.find('[name="project[packages_enabled]"]').props().disabledInput).toEqual(
        true,
      );
    });
  });

  describe('Pages', () => {
    it.each`
      pagesAvailable | pagesAccessControlEnabled | visibility
      ${true}        | ${true}                   | ${'show'}
      ${true}        | ${false}                  | ${'hide'}
      ${false}       | ${true}                   | ${'hide'}
      ${false}       | ${false}                  | ${'hide'}
    `(
      'should $visibility the page settings if pagesAvailable is $pagesAvailable and pagesAccessControlEnabled is $pagesAccessControlEnabled',
      ({ pagesAvailable, pagesAccessControlEnabled, visibility }) => {
        const wrapper = shallowMount(settingsPanel, {
          propsData: { ...defaultSettings, pagesAvailable, pagesAccessControlEnabled },
        });

        if (visibility === 'show') {
          expect(wrapper.find({ ref: 'pages-settings' }).exists()).toBe(true);
        } else {
          expect(wrapper.find({ ref: 'pages-settings' }).exists()).toBe(false);
        }
      },
    );

    it('should set the pages settings help path', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          pagesAvailable: true,
          pagesAccessControlEnabled: true,
        },
      });

      expect(wrapper.find({ ref: 'pages-settings' }).props().helpPath).toBe(
        defaultSettings.pagesHelpPath,
      );
    });
  });

  describe('Email notifications', () => {
    it('should show the disable email notifications input if emails an be disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          canDisableEmails: true,
        },
      });

      expect(wrapper.find({ ref: 'email-settings' }).exists()).toBe(true);
    });

    it('should hide the disable email notifications input if emails cannot be disabled', () => {
      const wrapper = shallowMount(settingsPanel, {
        propsData: {
          ...defaultSettings,
          canDisableEmails: false,
        },
      });

      expect(wrapper.find({ ref: 'email-settings' }).exists()).toBe(false);
    });
  });
});
