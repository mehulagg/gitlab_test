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
