import { extractCurrentDiscussionIndex, extractDesign } from '../../utils/design_management_utils';

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

export const transformNewDiscussionComment = (cacheData, { createNote, discussionId }) => {
  const design = extractDesign(cacheData);
  const currentDiscussionIndex = extractCurrentDiscussionIndex(design.discussions, discussionId);
  const currentDiscussion = design.discussions.edges[currentDiscussionIndex];

  const updatedDiscussionNotes = [
    ...currentDiscussion.node.notes.edges,
    {
      __typename: 'NoteEdge',
      node: createNote.note,
    },
  ];

  const updatedDiscussion = {
    ...currentDiscussion,
    node: {
      ...currentDiscussion.node,
      notes: {
        ...currentDiscussion.node.notes,
        edges: updatedDiscussionNotes,
      },
    },
  };

  const updatedDiscussions = [
    ...design.discussions.edges.slice(0, currentDiscussionIndex),
    updatedDiscussion,
    ...design.discussions.edges.slice(currentDiscussionIndex + 1),
  ];

  const updatedDesign = {
    __typename: 'DesignEdge',
    node: {
      ...design,
      discussions: {
        ...design.discussions,
        edges: updatedDiscussions,
      },
      notesCount: design.notesCount + 1,
    },
  };

  const updatedDesigns = {
    ...cacheData.project.issue.designCollection.designs,
    edges: [updatedDesign, ...cacheData.project.issue.designCollection.designs.edges.slice(1)],
  };

  return {
    project: {
      ...cacheData.project,
      issue: {
        ...cacheData.project.issue,
        designCollection: {
          ...cacheData.project.issue.designCollection,
          designs: updatedDesigns,
        },
      },
    },
  };
};

export const transformNewImageDiffNote = (cacheData, createImageDiffNote) => {
  const newDiscussion = {
    __typename: 'DiscussionEdge',
    node: {
      // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      __typename: 'Discussion',
      id: createImageDiffNote.note.discussion.id,
      replyId: createImageDiffNote.note.discussion.replyId,
      notes: {
        __typename: 'NoteConnection',
        edges: [
          {
            __typename: 'NoteEdge',
            node: createImageDiffNote.note,
          },
        ],
      },
    },
  };

  const design = extractDesign(cacheData);
  const updatedDiscussions = [...design.discussions.edges, newDiscussion];

  const updatedDesign = {
    __typename: 'DesignEdge',
    node: {
      ...design,
      discussions: {
        ...design.discussions,
        edges: updatedDiscussions,
      },
      notesCount: design.notesCount + 1,
    },
  };

  const updatedDesigns = {
    ...cacheData.project.issue.designCollection.designs,
    edges: [updatedDesign, ...cacheData.project.issue.designCollection.designs.edges.slice(1)],
  };

  return {
    project: {
      ...cacheData.project,
      issue: {
        ...cacheData.project.issue,
        designCollection: {
          ...cacheData.project.issue.designCollection,
          designs: updatedDesigns,
        },
      },
    },
  };
};
