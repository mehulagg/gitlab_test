import { mount } from '@vue/test-utils';
import PackageInstallation from 'ee/packages/components/installation.vue';

describe('PackageInstallation', () => {
  let wrapper;

  const packageScope = '@fake-scope';
  const packageName = 'my-package';
  const packageScopeName = `${packageScope}/${packageName}`;
  const registryUrl = 'https://gitlab.com/api/v4/packages/npm/';

  const defaultProps = {
    name: packageScopeName,
    registryUrl: `${registryUrl}package_name`,
    helpUrl: 'foo',
  };

  const npmInstall = `npm i ${packageScopeName}`;
  const npmSetup = `echo ${packageScope}:registry=${registryUrl} >> .npmrc`;
  const yarnInstall = `yarn add ${packageScopeName}`;
  const yarnSetup = `echo \\"${packageScope}:registry\\" \\"${registryUrl}\\" >> .yarnrc`;

  const installCommand = type => wrapper.find(`.js-${type}-install > input`);
  const setupCommand = type => wrapper.find(`.js-${type}-setup > input`);

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = mount(PackageInstallation, {
      propsData,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders the correct npm commands', () => {
    createComponent();

    expect(installCommand('npm').element.value).toBe(npmInstall);
    expect(setupCommand('npm').element.value).toBe(npmSetup);
  });

  it('renders the correct yarn commands', () => {
    createComponent();

    expect(installCommand('yarn').element.value).toBe(yarnInstall);
    expect(setupCommand('yarn').element.value).toBe(yarnSetup);
  });
});
