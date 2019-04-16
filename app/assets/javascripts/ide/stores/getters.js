import { getChangesCountForFiles, filePathMatches } from './utils';
import { activityBarViews, packageJsonPath } from '../constants';

export default {
  activeFile: state => state.openFiles.find(file => file.active) || null,

  addedFiles: state => state.changedFiles.filter(f => f.tempFile),

  modifiedFiles: state => state.changedFiles.filter(f => !f.tempFile),

  projectsWithTrees: state =>
    Object.keys(state.projects).map(projectId => {
      const project = state.projects[projectId];

      return {
        ...project,
        branches: Object.keys(project.branches).map(branchId => {
          const branch = project.branches[branchId];

          return {
            ...branch,
            tree: state.trees[branch.treeId],
          };
        }),
      };
    }),

  currentMergeRequest: state => {
    if (
      state.projects[state.currentProjectId] &&
      state.projects[state.currentProjectId].mergeRequests
    ) {
      return state.projects[state.currentProjectId].mergeRequests[state.currentMergeRequestId];
    }
    return null;
  },

  currentProject: state => state.projects[state.currentProjectId],

  currentTree: state => state.trees[`${state.currentProjectId}/${state.currentBranchId}`],

  hasChanges: state => !!state.changedFiles.length || !!state.stagedFiles.length,

  hasMergeRequest: state => !!state.currentMergeRequestId,

  allBlobs: state =>
    Object.keys(state.entries)
      .reduce((acc, key) => {
        const entry = state.entries[key];

        if (entry.type === 'blob') {
          acc.push(entry);
        }

        return acc;
      }, [])
      .sort((a, b) => b.lastOpenedAt - a.lastOpenedAt),

  getChangedFile: state => path => state.changedFiles.find(f => f.path === path),
  getStagedFile: state => path => state.stagedFiles.find(f => f.path === path),

  lastOpenedFile: state =>
    [...state.changedFiles, ...state.stagedFiles].sort(
      (a, b) => b.lastOpenedAt - a.lastOpenedAt,
    )[0],

  isEditModeActive: state => state.currentActivityView === activityBarViews.edit,
  isCommitModeActive: state => state.currentActivityView === activityBarViews.commit,
  isReviewModeActive: state => state.currentActivityView === activityBarViews.review,

  someUncommittedChanges: state => !!(state.changedFiles.length || state.stagedFiles.length),

  getChangesInFolder: state => path => {
    const changedFilesCount = state.changedFiles.filter(f => filePathMatches(f.path, path)).length;
    const stagedFilesCount = state.stagedFiles.filter(
      f => filePathMatches(f.path, path) && !getChangedFile(state)(f.path),
    ).length;

    return changedFilesCount + stagedFilesCount;
  },

  getUnstagedFilesCountForPath: state => path => getChangesCountForFiles(state.changedFiles, path),

  getStagedFilesCountForPath: state => path => getChangesCountForFiles(state.stagedFiles, path),

  lastCommit: (state, getters) => {
    const branch = getters.currentProject && getters.currentBranch;

    return branch ? branch.commit : null;
  },

  currentBranch: (state, getters) =>
    getters.currentProject && getters.currentProject.branches[state.currentBranchId],

  packageJson: state => state.entries[packageJsonPath],
};
