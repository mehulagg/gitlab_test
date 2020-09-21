import { generateConanRecipe } from '../utils';
import { PackageType } from '../../shared/constants';
import { getPackageTypeLabel } from '../../shared/utils';
import { NpmManager } from '../constants';

export const packagePipeline = ({ packageEntity }) => {
  return packageEntity?.pipeline || null;
};

export const packageTypeDisplay = ({ packageEntity }) => {
  return getPackageTypeLabel(packageEntity.package_type);
};

export const packageIcon = ({ packageEntity }) => {
  if (packageEntity.package_type === PackageType.NUGET) {
    return packageEntity.nuget_metadatum?.icon_url || null;
  }

  return null;
};

export const conanInstallationCommand = ({ packageEntity }) => {
  const recipe = generateConanRecipe(packageEntity);

  // eslint-disable-next-line @gitlab/require-i18n-strings
  return `conan install ${recipe} --remote=gitlab`;
};

export const conanSetupCommand = ({ conanPath }) =>
  // eslint-disable-next-line @gitlab/require-i18n-strings
  `conan remote add gitlab ${conanPath}`;

export const mavenInstallationXml = ({ packageEntity = {} }) => {
  const {
    app_group: appGroup = '',
    app_name: appName = '',
    app_version: appVersion = '',
  } = packageEntity.maven_metadatum;

  return `<dependency>
  <groupId>${appGroup}</groupId>
  <artifactId>${appName}</artifactId>
  <version>${appVersion}</version>
</dependency>`;
};

export const mavenInstallationCommand = ({ packageEntity = {} }) => {
  const {
    app_group: group = '',
    app_name: name = '',
    app_version: version = '',
  } = packageEntity.maven_metadatum;

  return `mvn dependency:get -Dartifact=${group}:${name}:${version}`;
};

export const mavenSetupXml = ({ mavenPath }) => `<repositories>
  <repository>
    <id>gitlab-maven</id>
    <url>${mavenPath}</url>
  </repository>
</repositories>

<distributionManagement>
  <repository>
    <id>gitlab-maven</id>
    <url>${mavenPath}</url>
  </repository>

  <snapshotRepository>
    <id>gitlab-maven</id>
    <url>${mavenPath}</url>
  </snapshotRepository>
</distributionManagement>`;

export const npmInstallationCommand = ({ packageEntity }) => (type = NpmManager.NPM) => {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  const instruction = type === NpmManager.NPM ? 'npm i' : 'yarn add';

  return `${instruction} ${packageEntity.name}`;
};

export const npmSetupCommand = ({ packageEntity, npmPath }) => (type = NpmManager.NPM) => {
  const scope = packageEntity.name.substring(0, packageEntity.name.indexOf('/'));

  if (type === NpmManager.NPM) {
    return `echo ${scope}:registry=${npmPath}/ >> .npmrc`;
  }

  return `echo \\"${scope}:registry\\" \\"${npmPath}/\\" >> .yarnrc`;
};

export const nugetInstallationCommand = ({ packageEntity }) =>
  `nuget install ${packageEntity.name} -Source "GitLab"`;

export const nugetSetupCommand = ({ nugetPath }) =>
  `nuget source Add -Name "GitLab" -Source "${nugetPath}" -UserName <your_username> -Password <your_token>`;

export const pypiPipCommand = ({ pypiPath, packageEntity }) =>
  // eslint-disable-next-line @gitlab/require-i18n-strings
  `pip install ${packageEntity.name} --extra-index-url ${pypiPath}`;

export const pypiSetupCommand = ({ pypiSetupPath }) => `[gitlab]
repository = ${pypiSetupPath}
username = __token__
password = <your personal access token>`;

export const composerRegistryInclude = ({ composerPath }) => {
  const base = { type: 'composer', url: composerPath };
  return JSON.stringify(base);
};
export const composerPackageInclude = ({ packageEntity }) => {
  const base = { [packageEntity.name]: packageEntity.version };
  return JSON.stringify(base);
};
