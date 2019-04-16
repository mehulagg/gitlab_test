export default {
  namespaceSelectOptions: state => {
    const serializedNamespaces = state.namespaces.map(({ fullPath }) => ({
      id: fullPath,
      text: fullPath,
    }));

    return [
      { text: 'Groups', children: serializedNamespaces },
      {
        text: 'Users',
        children: [{ id: state.defaultTargetNamespace, text: state.defaultTargetNamespace }],
      },
    ];
  },

  isImportingAnyRepo: state => state.reposBeingImported.length > 0,

  hasProviderRepos: state => state.providerRepos.length > 0,

  hasImportedProjects: state => state.importedProjects.length > 0,
};
