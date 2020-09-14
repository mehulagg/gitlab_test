export const designListQueryResponse = {
  data: {
    project: {
      id: '1',
      issue: {
        designCollection: {
          designs: {
            nodes: [
              {
                id: '1',
                event: 'NONE',
                filename: 'fox_1.jpg',
                notesCount: 3,
                image: 'image-1',
                imageV432x230: 'image-1',
                currentUserTodos: {
                  nodes: [],
                },
              },
              {
                id: '2',
                event: 'NONE',
                filename: 'fox_2.jpg',
                notesCount: 2,
                image: 'image-2',
                imageV432x230: 'image-2',
                currentUserTodos: {
                  nodes: [],
                },
              },
              {
                id: '3',
                event: 'NONE',
                filename: 'fox_3.jpg',
                notesCount: 1,
                image: 'image-3',
                imageV432x230: 'image-3',
                currentUserTodos: {
                  nodes: [],
                },
              },
            ],
          },
          versions: {
            nodes: [],
          },
        },
      },
    },
  },
};

export const permissionsQueryResponse = {
  data: {
    project: {
      id: '1',
      issue: {
        userPermissions: { createDesign: true },
      },
    },
  },
};

export const reorderedDesigns = [
  {
    id: '2',
    event: 'NONE',
    filename: 'fox_2.jpg',
    notesCount: 2,
    image: 'image-2',
    imageV432x230: 'image-2',
    currentUserTodos: {
      nodes: [],
    },
  },
  {
    id: '1',
    event: 'NONE',
    filename: 'fox_1.jpg',
    notesCount: 3,
    image: 'image-1',
    imageV432x230: 'image-1',
    currentUserTodos: {
      nodes: [],
    },
  },
  {
    id: '3',
    event: 'NONE',
    filename: 'fox_3.jpg',
    notesCount: 1,
    image: 'image-3',
    imageV432x230: 'image-3',
    currentUserTodos: {
      nodes: [],
    },
  },
];

export const moveDesignMutationResponse = {
  data: {
    designManagementMove: {
      designCollection: {
        designs: {
          nodes: [...reorderedDesigns],
        },
      },
      errors: [],
    },
  },
};

export const moveDesignMutationResponseWithErrors = {
  data: {
    designManagementMove: {
      designCollection: {
        designs: {
          nodes: [...reorderedDesigns],
        },
      },
      errors: ['Houston, we have a problem'],
    },
  },
};
