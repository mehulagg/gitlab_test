export default () => ({
  projectId: null,
  tagName: null,
  releasesPagePath: null,
  cancelPath: null,
  markdownDocsPath: null,
  markdownPreviewPath: null,
  updateReleaseApiDocsPath: null,

  release: null,

  isFetchingRelease: false,
  fetchError: null,

  isUpdatingRelease: false,
  updateError: null,
});
