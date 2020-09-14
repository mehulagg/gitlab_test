import { mockTracking, unmockTracking } from 'helpers/tracking_helper';
import Api from '~/api';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';

import {
  DEFAULT_TARGET_BRANCH,
  SUBMIT_CHANGES_BRANCH_ERROR,
  SUBMIT_CHANGES_COMMIT_ERROR,
  SUBMIT_CHANGES_MERGE_REQUEST_ERROR,
  TRACKING_ACTION_CREATE_COMMIT,
  TRACKING_ACTION_CREATE_MERGE_REQUEST,
} from '~/static_site_editor/constants';
import generateBranchName from '~/static_site_editor/services/generate_branch_name';
import submitContentChanges from '~/static_site_editor/services/submit_content_changes';

import {
  username,
  projectId,
  commitBranchResponse,
  commitMultipleResponse,
  createMergeRequestResponse,
  sourcePath,
  sourceContentYAML as content,
  trackingCategory,
  images,
} from '../mock_data';

jest.mock('~/static_site_editor/services/generate_branch_name');

describe('submitContentChanges', () => {
  const mergeRequestTitle = `Update ${sourcePath} file`;
  const branch = 'branch-name';
  let trackingSpy;
  let origPage;

  beforeEach(() => {
    jest.spyOn(Api, 'createBranch').mockResolvedValue({ data: commitBranchResponse });
    jest.spyOn(Api, 'commitMultiple').mockResolvedValue({ data: commitMultipleResponse });
    jest
      .spyOn(Api, 'createProjectMergeRequest')
      .mockResolvedValue({ data: createMergeRequestResponse });

    generateBranchName.mockReturnValue(branch);

    origPage = document.body.dataset.page;
    document.body.dataset.page = trackingCategory;
    trackingSpy = mockTracking(document.body.dataset.page, undefined, jest.spyOn);
  });

  afterEach(() => {
    document.body.dataset.page = origPage;
    unmockTracking();
  });

  it('creates a branch named after the username and target branch', () => {
    return submitContentChanges({ username, projectId }).then(() => {
      expect(Api.createBranch).toHaveBeenCalledWith(projectId, {
        ref: DEFAULT_TARGET_BRANCH,
        branch,
      });
    });
  });

  it('notifies error when branch could not be created', () => {
    Api.createBranch.mockRejectedValueOnce();

    return expect(submitContentChanges({ username, projectId })).rejects.toThrow(
      SUBMIT_CHANGES_BRANCH_ERROR,
    );
  });

  it('commits the content changes to the branch when creating branch succeeds', () => {
    return submitContentChanges({ username, projectId, sourcePath, content, images }).then(() => {
      expect(Api.commitMultiple).toHaveBeenCalledWith(projectId, {
        branch,
        commit_message: mergeRequestTitle,
        actions: [
          {
            action: 'update',
            file_path: sourcePath,
            content,
          },
          {
            action: 'create',
            content: 'image1-content',
            encoding: 'base64',
            file_path: 'path/to/image1.png',
          },
        ],
      });
    });
  });

  it('does not commit an image if it has been removed from the content', () => {
    const contentWithoutImages = '## Content without images';
    return submitContentChanges({
      username,
      projectId,
      sourcePath,
      content: contentWithoutImages,
      images,
    }).then(() => {
      expect(Api.commitMultiple).toHaveBeenCalledWith(projectId, {
        branch,
        commit_message: mergeRequestTitle,
        actions: [
          {
            action: 'update',
            file_path: sourcePath,
            content: contentWithoutImages,
          },
        ],
      });
    });
  });

  it('notifies error when content could not be committed', () => {
    Api.commitMultiple.mockRejectedValueOnce();

    return expect(submitContentChanges({ username, projectId, images })).rejects.toThrow(
      SUBMIT_CHANGES_COMMIT_ERROR,
    );
  });

  it('creates a merge request when commiting changes succeeds', () => {
    return submitContentChanges({ username, projectId, sourcePath, content, images }).then(() => {
      expect(Api.createProjectMergeRequest).toHaveBeenCalledWith(
        projectId,
        convertObjectPropsToSnakeCase({
          title: mergeRequestTitle,
          targetBranch: DEFAULT_TARGET_BRANCH,
          sourceBranch: branch,
        }),
      );
    });
  });

  it('notifies error when merge request could not be created', () => {
    Api.createProjectMergeRequest.mockRejectedValueOnce();

    return expect(submitContentChanges({ username, projectId, images })).rejects.toThrow(
      SUBMIT_CHANGES_MERGE_REQUEST_ERROR,
    );
  });

  describe('when changes are submitted successfully', () => {
    let result;

    beforeEach(() => {
      return submitContentChanges({ username, projectId, sourcePath, content, images }).then(
        _result => {
          result = _result;
        },
      );
    });

    it('returns the branch name', () => {
      expect(result).toMatchObject({ branch: { label: branch } });
    });

    it('returns commit short id and web url', () => {
      expect(result).toMatchObject({
        commit: {
          label: commitMultipleResponse.short_id,
          url: commitMultipleResponse.web_url,
        },
      });
    });

    it('returns merge request iid and web url', () => {
      expect(result).toMatchObject({
        mergeRequest: {
          label: createMergeRequestResponse.iid,
          url: createMergeRequestResponse.web_url,
        },
      });
    });
  });

  describe('sends the correct tracking event', () => {
    beforeEach(() => {
      return submitContentChanges({ username, projectId, sourcePath, content, images });
    });

    it('for committing changes', () => {
      expect(trackingSpy).toHaveBeenCalledWith(
        document.body.dataset.page,
        TRACKING_ACTION_CREATE_COMMIT,
      );
    });

    it('for creating a merge request', () => {
      expect(trackingSpy).toHaveBeenCalledWith(
        document.body.dataset.page,
        TRACKING_ACTION_CREATE_MERGE_REQUEST,
      );
    });
  });
});
