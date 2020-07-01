import Vue from 'vue';
import createRouter from './router';
import App from './components/app.vue';
import Breadcrumbs from './components/breadcrumbs.vue';
import LastCommit from './components/last_commit.vue';
import TreeActionLink from './components/tree_action_link.vue';
import DirectoryDownloadLinks from './components/directory_download_links.vue';
import apolloProvider from './graphql';
import { setTitle } from './utils/title';
import { updateFormAction } from './utils/dom';
import { parseBoolean } from '../lib/utils/common_utils';
import { webIDEUrl } from '../lib/utils/url_utility';
import { __ } from '../locale';
import pathLastCommit from './queries/pathLastCommit.query.graphql';
import getPermissions from './queries/getPermissions.query.graphql';
import getFiles from './queries/getFiles.query.graphql';

export default function setupVueRepositoryList() {
  const el = document.getElementById('js-tree-list');
  const { dataset } = el;
  const { projectPath, projectShortPath, ref, escapedRef, fullName } = dataset;
  const router = createRouter(projectPath, escapedRef);

  const myRegex = /-\/tree\/master\/(.+$)/;
  const match = window.location.href.match(myRegex);

  const currentPath = match ? match[1] : '';

  apolloProvider.clients.defaultClient
    .watchQuery({
      query: pathLastCommit,
      variables: {
        projectPath,
        ref,
        path: currentPath,
      },
    })
    .subscribe();

  apolloProvider.clients.defaultClient
    .watchQuery({
      query: getPermissions,
      variables: {
        projectPath,
      },
    })
    .subscribe();

  apolloProvider.clients.defaultClient
    .watchQuery({
      query: getFiles,
      variables: {
        projectPath,
        ref,
        path: currentPath || '/',
        nextPageCursor: '',
        pageSize: 100,
        vueLfsEnabled: gon.features?.vueFileListLfsBadge || false,
      },
    })
    .subscribe();

  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      projectPath,
      projectShortPath,
      ref,
      escapedRef,
      vueFileListLfsBadge: gon.features?.vueFileListLfsBadge || false,
      commits: [],
    },
  });

  router.afterEach(({ params: { path } }) => {
    setTitle(path, ref, fullName);
  });

  const breadcrumbEl = document.getElementById('js-repo-breadcrumb');

  if (breadcrumbEl) {
    const {
      canCollaborate,
      canEditTree,
      newBranchPath,
      newTagPath,
      newBlobPath,
      forkNewBlobPath,
      forkNewDirectoryPath,
      forkUploadBlobPath,
      uploadPath,
      newDirPath,
    } = breadcrumbEl.dataset;

    router.afterEach(({ params: { path = '/' } }) => {
      updateFormAction('.js-upload-blob-form', uploadPath, path);
      updateFormAction('.js-create-dir-form', newDirPath, path);
    });

    // eslint-disable-next-line no-new
    new Vue({
      el: breadcrumbEl,
      router,
      apolloProvider,
      render(h) {
        return h(Breadcrumbs, {
          props: {
            currentPath: this.$route.params.path,
            canCollaborate: parseBoolean(canCollaborate),
            canEditTree: parseBoolean(canEditTree),
            newBranchPath,
            newTagPath,
            newBlobPath,
            forkNewBlobPath,
            forkNewDirectoryPath,
            forkUploadBlobPath,
          },
        });
      },
    });
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: document.getElementById('js-last-commit'),
    router,
    apolloProvider,
    render(h) {
      return h(LastCommit, {
        props: {
          currentPath: this.$route.params.path,
        },
      });
    },
  });

  const treeHistoryLinkEl = document.getElementById('js-tree-history-link');
  const { historyLink } = treeHistoryLinkEl.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el: treeHistoryLinkEl,
    router,
    render(h) {
      return h(TreeActionLink, {
        props: {
          path: `${historyLink}/${
            this.$route.params.path ? encodeURIComponent(this.$route.params.path) : ''
          }`,
          text: __('History'),
        },
      });
    },
  });

  const webIdeLinkEl = document.getElementById('js-tree-web-ide-link');

  if (webIdeLinkEl) {
    // eslint-disable-next-line no-new
    new Vue({
      el: webIdeLinkEl,
      router,
      render(h) {
        return h(TreeActionLink, {
          props: {
            path: webIDEUrl(`/${projectPath}/edit/${ref}/-/${this.$route.params.path || ''}`),
            text: __('Web IDE'),
            cssClass: 'qa-web-ide-button',
          },
        });
      },
    });
  }

  const directoryDownloadLinks = document.getElementById('js-directory-downloads');

  if (directoryDownloadLinks) {
    // eslint-disable-next-line no-new
    new Vue({
      el: directoryDownloadLinks,
      router,
      render(h) {
        const currentPath = this.$route.params.path || '/';

        if (currentPath !== '/') {
          return h(DirectoryDownloadLinks, {
            props: {
              currentPath: currentPath.replace(/^\//, ''),
              links: JSON.parse(directoryDownloadLinks.dataset.links),
            },
          });
        }

        return null;
      },
    });
  }

  // eslint-disable-next-line no-new
  new Vue({
    el,
    router,
    apolloProvider,
    render(h) {
      return h(App);
    },
  });

  return { router, data: dataset };
}
