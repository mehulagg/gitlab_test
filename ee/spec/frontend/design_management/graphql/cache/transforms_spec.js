import {
  transformDesignUpload,
  transformDesignDeletion,
  transformNewVersion,
  transformNewDiscussionComment,
  transformNewImageDiffNote,
} from 'ee/design_management/graphql/cache/transforms';
import {
  designUploadTransformation,
  designDeletionTransformation,
  newVersionTransformation,
  newDiscussionCommentTransformation,
  newImageDiffNoteTransformation,
} from '../mock_data';
import mockDesign from '../../mock_data/design';
import mockVersion from '../../mock_data/version';
import mockNote from '../../mock_data/note';
import mockDiffNote from '../../mock_data/diff_note';

describe('Apollo cache transformations', () => {
  describe('Design upload', () => {
    const cacheData = {
      project: {
        __typename: 'Project',
        issue: {
          __typename: 'Issue',
          designCollection: {
            __typename: 'DesignCollection',
            designs: {
              edges: [],
              __typename: 'DesignConnection',
            },
            versions: {
              edges: [],
              __typename: 'DesignVersionConnection',
            },
          },
        },
      },
    };

    it('transform produces correct transformation', () => {
      const transformed = transformDesignUpload(cacheData, { designs: [mockDesign] });

      expect(transformed).toEqual(designUploadTransformation);
    });
    it('transform does not mutate input data', () => {
      const newData = { designs: [mockDesign] };
      const transformed = transformDesignUpload(cacheData, newData);

      expect(transformed).not.toEqual(cacheData);
      expect(cacheData).toEqual(cacheData);
      expect(newData).toEqual(newData);
    });
  });

  describe('Design delete', () => {
    const cacheData = {
      project: {
        __typename: 'Project',
        issue: {
          __typename: 'Issue',
          designCollection: {
            __typename: 'DesignCollection',
            designs: {
              edges: [
                {
                  __typename: 'DesignEdge',
                  node: mockDesign,
                },
              ],
              __typename: 'DesignConnection',
            },
            versions: {
              edges: [],
              __typename: 'DesignVersionConnection',
            },
          },
        },
      },
    };

    it('produces the correct transformation', () => {
      const deletedDesigns = [mockDesign.filename];
      const transformed = transformDesignDeletion(cacheData, deletedDesigns);

      expect(transformed).toEqual(designDeletionTransformation);
    });
    it('transform does not mutate input data', () => {
      const deletedDesigns = [mockDesign.filename];
      const transformed = transformDesignDeletion(cacheData, deletedDesigns);

      expect(transformed).not.toEqual(cacheData);
      expect(cacheData).toEqual(cacheData);
      expect(deletedDesigns).toEqual(deletedDesigns);
    });
  });

  describe('New version', () => {
    const cacheData = {
      project: {
        __typename: 'Project',
        issue: {
          __typename: 'Issue',
          designCollection: {
            __typename: 'DesignCollection',
            designs: {
              edges: [],
              __typename: 'DesignConnection',
            },
            versions: {
              edges: [],
              __typename: 'DesignVersionConnection',
            },
          },
        },
      },
    };

    it('produces the correct transformation', () => {
      const newVersion = mockVersion;
      const transformed = transformNewVersion(cacheData, newVersion);

      expect(transformed).toEqual(newVersionTransformation);
    });
    it('transform does not mutate input data', () => {
      const newVersion = mockVersion;
      const transformed = transformNewVersion(cacheData, newVersion);

      expect(transformed).not.toEqual(cacheData);
      expect(cacheData).toEqual(cacheData);
      expect(newVersion).toEqual(newVersion);
    });
  });

  describe('New discussion comment', () => {
    const cacheData = {
      project: {
        __typename: 'Project',
        issue: {
          __typename: 'Issue',
          designCollection: {
            __typename: 'DesignCollection',
            designs: {
              edges: [
                {
                  __typename: 'DesignEdge',
                  node: mockDesign,
                },
              ],
              __typename: 'DesignConnection',
            },
            versions: {
              edges: [],
              __typename: 'DesignVersionConnection',
            },
          },
        },
      },
    };

    it('produces the correct transformation', () => {
      const newCommentData = {
        createNote: {
          note: mockNote,
        },
        discussionId: 'discussion-id',
      };
      const transformed = transformNewDiscussionComment(cacheData, newCommentData);
      expect(transformed).toEqual(newDiscussionCommentTransformation);
    });
    it('transform does not mutate input data', () => {
      const newCommentData = {
        createNote: {
          note: mockNote,
        },
        discussionId: 'discussion-id',
      };
      const transformed = transformNewDiscussionComment(cacheData, newCommentData);

      expect(transformed).not.toEqual(cacheData);
      expect(cacheData).toEqual(cacheData);
      expect(newCommentData).toEqual(newCommentData);
    });
  });

  describe('New image diff note', () => {
    const cacheData = {
      project: {
        __typename: 'Project',
        issue: {
          __typename: 'Issue',
          designCollection: {
            __typename: 'DesignCollection',
            designs: {
              edges: [
                {
                  __typename: 'DesignEdge',
                  node: mockDesign,
                },
              ],
              __typename: 'DesignConnection',
            },
            versions: {
              edges: [],
              __typename: 'DesignVersionConnection',
            },
          },
        },
      },
    };

    it('produces the correct transformation', () => {
      const transformed = transformNewImageDiffNote(cacheData, mockDiffNote);
      expect(transformed).toEqual(newImageDiffNoteTransformation);
    });
    it('transform does not mutate input data', () => {
      const transformed = transformNewImageDiffNote(cacheData, mockDiffNote);

      expect(transformed).not.toEqual(cacheData);
      expect(cacheData).toEqual(cacheData);
      expect(mockDiffNote).toEqual(mockDiffNote);
    });
  });
});
