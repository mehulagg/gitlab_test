export const transformDesignUpload = (cacheData, designUploadData) => {
  const newDesigns = cacheData.project.issue.designCollection.designs.edges.reduce(
    (acc, design) => {
      if (!acc.find(d => d.filename === design.node.filename)) {
        acc.push(design.node);
      }

      return acc;
    },
    designUploadData.designs,
  );

  let newVersionNode;
  const findNewVersions = designUploadData.designs.find(design => design.versions);

  if (findNewVersions) {
    const findNewVersionsEdges = findNewVersions.versions.edges;

    if (findNewVersionsEdges && findNewVersionsEdges.length) {
      newVersionNode = [findNewVersionsEdges[0]];
    }
  }

  const newVersions = [
    ...(newVersionNode || []),
    ...cacheData.project.issue.designCollection.versions.edges,
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
    project: {
      ...cacheData.project,
      issue: {
        ...cacheData.project.issue,
        designCollection: updatedDesigns,
      },
    },
  };
};

export const transformNewVersion = (cacheData, newVersion) => {
  const newEdge = { node: newVersion, __typename: 'DesignVersionEdge' };

  return {
    project: {
      ...cacheData.project,
      issue: {
        ...cacheData.project.issue,
        designCollection: {
          ...cacheData.project.issue.designCollection,
          versions: {
            ...cacheData.project.issue.designCollection.versions,
            edges: [newEdge, ...cacheData.project.issue.designCollection.versions.edges],
          },
        },
      },
    },
  };
};

export const transformDesignDeletion = (cacheData, deletedDesigns) => {
  const updatedDesignList = cacheData.project.issue.designCollection.designs.edges.filter(
    ({ node }) => !deletedDesigns.includes(node.filename),
  );

  return {
    project: {
      ...cacheData.project,
      issue: {
        ...cacheData.project.issue,
        designCollection: {
          ...cacheData.project.issue.designCollection,
          designs: {
            ...cacheData.project.issue.designCollection.designs,
            edges: [...updatedDesignList],
          },
        },
      },
    },
  };
};
