/* eslint-disable no-new */

import $ from 'jquery';
import Diff from '~/diff';
import ZenMode from '~/zen_mode';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import MiniPipelineGraph from '~/mini_pipeline_graph_dropdown';
import initNotes from '~/init_notes';
import initChangesDropdown from '~/init_changes_dropdown';
import { fetchCommitMergeRequests } from '~/commit_merge_requests';
import '~/sourcegraph/load';
import { handleLocationHash } from '~/lib/utils/common_utils';
import axios from '~/lib/utils/axios_utils';
import syntaxHighlight from '~/syntax_highlight';
import flash from '~/flash';
import { __ } from '~/locale';
import loadAwardsHandler from '~/awards_handler';

document.addEventListener('DOMContentLoaded', () => {
  const hasPerfBar = document.querySelector('.with-performance-bar');
  const performanceHeight = hasPerfBar ? 35 : 0;
  initChangesDropdown(document.querySelector('.navbar-gitlab').offsetHeight + performanceHeight);
  new ZenMode();
  new ShortcutsNavigation();
  new MiniPipelineGraph({
    container: '.js-commit-pipeline-graph',
  }).bindEvents();
  initNotes();
  // eslint-disable-next-line no-jquery/no-load
  $('.commit-info.branches').load(document.querySelector('.js-commit-box').dataset.commitPath);
  fetchCommitMergeRequests();

  const filesContainer = $('.js-diffs-batch');

  if (filesContainer.length) {
    const batchPath = filesContainer.data('diffFilesPath');

    axios
      .get(batchPath)
      .then(({ data }) => {
        filesContainer.html($(data.html));
        syntaxHighlight(filesContainer);
        handleLocationHash();
        new Diff();
      })
      .catch(() => {
        flash(__('An error occurred while retrieving diff files'));
      });
  } else {
    new Diff();
  }
  loadAwardsHandler();
});
