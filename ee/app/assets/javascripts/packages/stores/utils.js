export const createEmptyPackageJson = (project, packageEntity) => ({
  name: project.name,
  version: '1.0.0',
  description: project.description,
  repository: {
    type: 'git',
    url: project.http_url_to_repo,
  },
  dependencies: {
    [packageEntity.name]: packageEntity.version,
  },
  license: 'ISC',
});

export const addToPackageJson = (packageJson, packageEntity) => {
  // TODO: Something

  // eslint-disable-next-line no-console
  console.log(packageJson, packageEntity);

  return '';
};
