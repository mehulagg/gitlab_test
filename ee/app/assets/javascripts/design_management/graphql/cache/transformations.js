const updateCache = (store, query, data, transform) => {
  const cacheData = store.readQuery({
    query: query.query,
    variables: query.variables,
  });

  const newCacheData = transform(query, cacheData, data);

  store.writeQuery(newCacheData);
};

const transformDesignUpload = (query, cachedData, designManagementUpload) => {
  const newDesigns = cachedData.project.issue.designCollection.designs.edges.reduce(
    (acc, design) => {
      if (!acc.find(d => d.filename === design.node.filename)) {
        acc.push(design.node);
      }

      return acc;
    },
    designManagementUpload.designs,
  );

  let newVersionNode;
  const findNewVersions = designManagementUpload.designs.find(design => design.versions);

  if (findNewVersions) {
    const findNewVersionsEdges = findNewVersions.versions.edges;

    if (findNewVersionsEdges && findNewVersionsEdges.length) {
      newVersionNode = [findNewVersionsEdges[0]];
    }
  }

  const newVersions = [
    ...(newVersionNode || []),
    ...cachedData.project.issue.designCollection.versions.edges,
  ];

  const updatedDesigns = {
    __typename: 'DesignCollection',
    designs: {
      __typename: 'DesignConnection',
      edges: newDesigns.map(design => ({
        __typename: 'DesignEdge',
        node: design,
      })),
    },
    versions: {
      __typename: 'DesignVersionConnection',
      edges: newVersions,
    },
  };

  return {
    ...query,
    project: {
      ...cachedData.project,
      issue: {
        ...cachedData.issue,
        designCollection: updatedDesigns,
      },
    },
  };
};

export const afterDesignUpload = (store, query, data) => {
  updateCache(store, query, data, transformDesignUpload);
};
