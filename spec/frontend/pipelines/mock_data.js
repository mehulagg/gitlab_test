import {
  PIPELINE_CANCELED,
  PIPELINE_FAILED,
  PIPELINE_RUNNING,
} from '../../../app/assets/javascripts/pipelines/constants';

export const pipelineWithStages = {
  id: 20333396,
  user: {
    id: 128633,
    name: 'Rémy Coutable',
    username: 'rymai',
    state: 'active',
    avatar_url:
      'https://secure.gravatar.com/avatar/263da227929cc0035cb0eba512bcf81a?s=80\u0026d=identicon',
    web_url: 'https://gitlab.com/rymai',
    path: '/rymai',
  },
  active: true,
  coverage: '58.24',
  source: 'push',
  created_at: '2018-04-11T14:04:53.881Z',
  updated_at: '2018-04-11T14:05:00.792Z',
  path: '/gitlab-org/gitlab/pipelines/20333396',
  flags: {
    latest: true,
    stuck: false,
    auto_devops: false,
    yaml_errors: false,
    retryable: false,
    cancelable: true,
    failure_reason: false,
  },
  details: {
    status: {
      icon: 'status_running',
      text: 'running',
      label: 'running',
      group: 'running',
      has_details: true,
      details_path: '/gitlab-org/gitlab/pipelines/20333396',
      favicon:
        'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_running-2eb56be2871937954b2ba6d6f4ee9fdf7e5e1c146ac45f7be98119ccaca1aca9.ico',
    },
    duration: null,
    finished_at: null,
    stages: [
      {
        name: 'build',
        title: 'build: skipped',
        status: {
          icon: 'status_skipped',
          text: 'skipped',
          label: 'skipped',
          group: 'skipped',
          has_details: true,
          details_path: '/gitlab-org/gitlab/pipelines/20333396#build',
          favicon:
            'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_skipped-a2eee568a5bffdb494050c7b62dde241de9189280836288ac8923d369f16222d.ico',
        },
        path: '/gitlab-org/gitlab/pipelines/20333396#build',
        dropdown_path: '/gitlab-org/gitlab/pipelines/20333396/stage.json?stage=build',
      },
      {
        name: 'prepare',
        title: 'prepare: passed',
        status: {
          icon: 'status_success',
          text: 'passed',
          label: 'passed',
          group: 'success',
          has_details: true,
          details_path: '/gitlab-org/gitlab/pipelines/20333396#prepare',
          favicon:
            'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_success-26f59841becbef8c6fe414e9e74471d8bfd6a91b5855c19fe7f5923a40a7da47.ico',
        },
        path: '/gitlab-org/gitlab/pipelines/20333396#prepare',
        dropdown_path: '/gitlab-org/gitlab/pipelines/20333396/stage.json?stage=prepare',
      },
      {
        name: 'test',
        title: 'test: running',
        status: {
          icon: 'status_running',
          text: 'running',
          label: 'running',
          group: 'running',
          has_details: true,
          details_path: '/gitlab-org/gitlab/pipelines/20333396#test',
          favicon:
            'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_running-2eb56be2871937954b2ba6d6f4ee9fdf7e5e1c146ac45f7be98119ccaca1aca9.ico',
        },
        path: '/gitlab-org/gitlab/pipelines/20333396#test',
        dropdown_path: '/gitlab-org/gitlab/pipelines/20333396/stage.json?stage=test',
      },
      {
        name: 'post-test',
        title: 'post-test: created',
        status: {
          icon: 'status_created',
          text: 'created',
          label: 'created',
          group: 'created',
          has_details: true,
          details_path: '/gitlab-org/gitlab/pipelines/20333396#post-test',
          favicon:
            'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_created-e997aa0b7db73165df8a9d6803932b18d7b7cc37d604d2d96e378fea2dba9c5f.ico',
        },
        path: '/gitlab-org/gitlab/pipelines/20333396#post-test',
        dropdown_path: '/gitlab-org/gitlab/pipelines/20333396/stage.json?stage=post-test',
      },
      {
        name: 'pages',
        title: 'pages: created',
        status: {
          icon: 'status_created',
          text: 'created',
          label: 'created',
          group: 'created',
          has_details: true,
          details_path: '/gitlab-org/gitlab/pipelines/20333396#pages',
          favicon:
            'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_created-e997aa0b7db73165df8a9d6803932b18d7b7cc37d604d2d96e378fea2dba9c5f.ico',
        },
        path: '/gitlab-org/gitlab/pipelines/20333396#pages',
        dropdown_path: '/gitlab-org/gitlab/pipelines/20333396/stage.json?stage=pages',
      },
      {
        name: 'post-cleanup',
        title: 'post-cleanup: created',
        status: {
          icon: 'status_created',
          text: 'created',
          label: 'created',
          group: 'created',
          has_details: true,
          details_path: '/gitlab-org/gitlab/pipelines/20333396#post-cleanup',
          favicon:
            'https://assets.gitlab-static.net/assets/ci_favicons/favicon_status_created-e997aa0b7db73165df8a9d6803932b18d7b7cc37d604d2d96e378fea2dba9c5f.ico',
        },
        path: '/gitlab-org/gitlab/pipelines/20333396#post-cleanup',
        dropdown_path: '/gitlab-org/gitlab/pipelines/20333396/stage.json?stage=post-cleanup',
      },
    ],
    artifacts: [
      {
        name: 'gitlab:assets:compile',
        expired: false,
        expire_at: '2018-05-12T14:22:54.730Z',
        path: '/gitlab-org/gitlab/-/jobs/62411438/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411438/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411438/artifacts/browse',
      },
      {
        name: 'rspec-mysql 12 28',
        expired: false,
        expire_at: '2018-05-12T14:22:45.136Z',
        path: '/gitlab-org/gitlab/-/jobs/62411397/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411397/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411397/artifacts/browse',
      },
      {
        name: 'rspec-mysql 6 28',
        expired: false,
        expire_at: '2018-05-12T14:22:41.523Z',
        path: '/gitlab-org/gitlab/-/jobs/62411391/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411391/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411391/artifacts/browse',
      },
      {
        name: 'rspec-pg geo 0 1',
        expired: false,
        expire_at: '2018-05-12T14:22:13.287Z',
        path: '/gitlab-org/gitlab/-/jobs/62411353/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411353/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411353/artifacts/browse',
      },
      {
        name: 'rspec-mysql 0 28',
        expired: false,
        expire_at: '2018-05-12T14:22:06.834Z',
        path: '/gitlab-org/gitlab/-/jobs/62411385/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411385/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411385/artifacts/browse',
      },
      {
        name: 'spinach-mysql 0 2',
        expired: false,
        expire_at: '2018-05-12T14:21:51.409Z',
        path: '/gitlab-org/gitlab/-/jobs/62411423/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411423/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411423/artifacts/browse',
      },
      {
        name: 'karma',
        expired: false,
        expire_at: '2018-05-12T14:21:20.934Z',
        path: '/gitlab-org/gitlab/-/jobs/62411440/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411440/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411440/artifacts/browse',
      },
      {
        name: 'spinach-pg 0 2',
        expired: false,
        expire_at: '2018-05-12T14:20:01.028Z',
        path: '/gitlab-org/gitlab/-/jobs/62411419/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411419/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411419/artifacts/browse',
      },
      {
        name: 'spinach-pg 1 2',
        expired: false,
        expire_at: '2018-05-12T14:19:04.336Z',
        path: '/gitlab-org/gitlab/-/jobs/62411421/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411421/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411421/artifacts/browse',
      },
      {
        name: 'sast',
        expired: null,
        expire_at: null,
        path: '/gitlab-org/gitlab/-/jobs/62411442/artifacts/download',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411442/artifacts/browse',
      },
      {
        name: 'code_quality',
        expired: false,
        expire_at: '2018-04-18T14:16:24.484Z',
        path: '/gitlab-org/gitlab/-/jobs/62411441/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411441/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411441/artifacts/browse',
      },
      {
        name: 'cache gems',
        expired: null,
        expire_at: null,
        path: '/gitlab-org/gitlab/-/jobs/62411447/artifacts/download',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411447/artifacts/browse',
      },
      {
        name: 'dependency_scanning',
        expired: null,
        expire_at: null,
        path: '/gitlab-org/gitlab/-/jobs/62411443/artifacts/download',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411443/artifacts/browse',
      },
      {
        name: 'compile-assets',
        expired: false,
        expire_at: '2018-04-18T14:12:07.638Z',
        path: '/gitlab-org/gitlab/-/jobs/62411334/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411334/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411334/artifacts/browse',
      },
      {
        name: 'setup-test-env',
        expired: false,
        expire_at: '2018-04-18T14:10:27.024Z',
        path: '/gitlab-org/gitlab/-/jobs/62411336/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411336/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411336/artifacts/browse',
      },
      {
        name: 'retrieve-tests-metadata',
        expired: false,
        expire_at: '2018-05-12T14:06:35.926Z',
        path: '/gitlab-org/gitlab/-/jobs/62411333/artifacts/download',
        keep_path: '/gitlab-org/gitlab/-/jobs/62411333/artifacts/keep',
        browse_path: '/gitlab-org/gitlab/-/jobs/62411333/artifacts/browse',
      },
    ],
    manual_actions: [
      {
        name: 'package-and-qa',
        path: '/gitlab-org/gitlab/-/jobs/62411330/play',
        playable: true,
      },
      {
        name: 'review-docs-deploy',
        path: '/gitlab-org/gitlab/-/jobs/62411332/play',
        playable: true,
      },
    ],
  },
  ref: {
    name: 'master',
    path: '/gitlab-org/gitlab/commits/master',
    tag: false,
    branch: true,
  },
  commit: {
    id: 'e6a2885c503825792cb8a84a8731295e361bd059',
    short_id: 'e6a2885c',
    title: "Merge branch 'ce-to-ee-2018-04-11' into 'master'",
    created_at: '2018-04-11T14:04:39.000Z',
    parent_ids: [
      '5d9b5118f6055f72cff1a82b88133609912f2c1d',
      '6fdc6ee76a8062fe41b1a33f7c503334a6ebdc02',
    ],
    message:
      "Merge branch 'ce-to-ee-2018-04-11' into 'master'\n\nCE upstream - 2018-04-11 12:26 UTC\n\nSee merge request gitlab-org/gitlab-ee!5326",
    author_name: 'Rémy Coutable',
    author_email: 'remy@rymai.me',
    authored_date: '2018-04-11T14:04:39.000Z',
    committer_name: 'Rémy Coutable',
    committer_email: 'remy@rymai.me',
    committed_date: '2018-04-11T14:04:39.000Z',
    author: {
      id: 128633,
      name: 'Rémy Coutable',
      username: 'rymai',
      state: 'active',
      avatar_url:
        'https://secure.gravatar.com/avatar/263da227929cc0035cb0eba512bcf81a?s=80\u0026d=identicon',
      web_url: 'https://gitlab.com/rymai',
      path: '/rymai',
    },
    author_gravatar_url:
      'https://secure.gravatar.com/avatar/263da227929cc0035cb0eba512bcf81a?s=80\u0026d=identicon',
    commit_url:
      'https://gitlab.com/gitlab-org/gitlab/commit/e6a2885c503825792cb8a84a8731295e361bd059',
    commit_path: '/gitlab-org/gitlab/commit/e6a2885c503825792cb8a84a8731295e361bd059',
  },
  cancel_path: '/gitlab-org/gitlab/pipelines/20333396/cancel',
  triggered_by: null,
  triggered: [],
};

const threeWeeksAgo = new Date();
threeWeeksAgo.setDate(threeWeeksAgo.getDate() - 21);

export const mockPipelineHeader = {
  detailedStatus: {},
  id: 123,
  userPermissions: {
    destroyPipeline: true,
  },
  createdAt: threeWeeksAgo.toISOString(),
  user: {
    name: 'Foo',
    username: 'foobar',
    email: 'foo@bar.com',
    avatarUrl: 'link',
  },
};

export const mockFailedPipelineHeader = {
  ...mockPipelineHeader,
  status: PIPELINE_FAILED,
  retryable: true,
  cancelable: false,
  detailedStatus: {
    group: 'failed',
    icon: 'status_failed',
    label: 'failed',
    text: 'failed',
    detailsPath: 'path',
  },
};

export const mockRunningPipelineHeader = {
  ...mockPipelineHeader,
  status: PIPELINE_RUNNING,
  retryable: false,
  cancelable: true,
  detailedStatus: {
    group: 'running',
    icon: 'status_running',
    label: 'running',
    text: 'running',
    detailsPath: 'path',
  },
};

export const mockCancelledPipelineHeader = {
  ...mockPipelineHeader,
  status: PIPELINE_CANCELED,
  retryable: true,
  cancelable: false,
  detailedStatus: {
    group: 'cancelled',
    icon: 'status_cancelled',
    label: 'cancelled',
    text: 'cancelled',
    detailsPath: 'path',
  },
};

export const mockSuccessfulPipelineHeader = {
  ...mockPipelineHeader,
  status: 'SUCCESS',
  retryable: false,
  cancelable: false,
  detailedStatus: {
    group: 'success',
    icon: 'status_success',
    label: 'success',
    text: 'success',
    detailsPath: 'path',
  },
};

export const stageReply = {
  name: 'deploy',
  title: 'deploy: running',
  latest_statuses: [
    {
      id: 928,
      name: 'stop staging',
      started: false,
      build_path: '/twitter/flight/-/jobs/928',
      cancel_path: '/twitter/flight/-/jobs/928/cancel',
      playable: false,
      created_at: '2018-04-04T20:02:02.728Z',
      updated_at: '2018-04-04T20:02:02.766Z',
      status: {
        icon: 'status_pending',
        text: 'pending',
        label: 'pending',
        group: 'pending',
        tooltip: 'pending',
        has_details: true,
        details_path: '/twitter/flight/-/jobs/928',
        favicon:
          '/assets/ci_favicons/dev/favicon_status_pending-db32e1faf94b9f89530ac519790920d1f18ea8f6af6cd2e0a26cd6840cacf101.ico',
        action: {
          icon: 'cancel',
          title: 'Cancel',
          path: '/twitter/flight/-/jobs/928/cancel',
          method: 'post',
        },
      },
    },
    {
      id: 926,
      name: 'production',
      started: false,
      build_path: '/twitter/flight/-/jobs/926',
      retry_path: '/twitter/flight/-/jobs/926/retry',
      play_path: '/twitter/flight/-/jobs/926/play',
      playable: true,
      created_at: '2018-04-04T20:00:57.202Z',
      updated_at: '2018-04-04T20:11:13.110Z',
      status: {
        icon: 'status_canceled',
        text: 'canceled',
        label: 'manual play action',
        group: 'canceled',
        tooltip: 'canceled',
        has_details: true,
        details_path: '/twitter/flight/-/jobs/926',
        favicon:
          '/assets/ci_favicons/dev/favicon_status_canceled-5491840b9b6feafba0bc599cbd49ee9580321dc809683856cf1b0d51532b1af6.ico',
        action: {
          icon: 'play',
          title: 'Play',
          path: '/twitter/flight/-/jobs/926/play',
          method: 'post',
        },
      },
    },
    {
      id: 217,
      name: 'staging',
      started: '2018-03-07T08:41:46.234Z',
      build_path: '/twitter/flight/-/jobs/217',
      retry_path: '/twitter/flight/-/jobs/217/retry',
      playable: false,
      created_at: '2018-03-07T14:41:58.093Z',
      updated_at: '2018-03-07T14:41:58.093Z',
      status: {
        icon: 'status_success',
        text: 'passed',
        label: 'passed',
        group: 'success',
        tooltip: 'passed',
        has_details: true,
        details_path: '/twitter/flight/-/jobs/217',
        favicon:
          '/assets/ci_favicons/dev/favicon_status_success-308b4fc054cdd1b68d0865e6cfb7b02e92e3472f201507418f8eddb74ac11a59.ico',
        action: {
          icon: 'retry',
          title: 'Retry',
          path: '/twitter/flight/-/jobs/217/retry',
          method: 'post',
        },
      },
    },
  ],
  status: {
    icon: 'status_running',
    text: 'running',
    label: 'running',
    group: 'running',
    tooltip: 'running',
    has_details: true,
    details_path: '/twitter/flight/pipelines/13#deploy',
    favicon:
      '/assets/ci_favicons/dev/favicon_status_running-c3ad2fc53ea6079c174e5b6c1351ff349e99ec3af5a5622fb77b0fe53ea279c1.ico',
  },
  path: '/twitter/flight/pipelines/13#deploy',
  dropdown_path: '/twitter/flight/pipelines/13/stage.json?stage=deploy',
};

export const users = [
  {
    id: 1,
    name: 'Administrator',
    username: 'root',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
    web_url: 'http://192.168.1.22:3000/root',
  },
  {
    id: 10,
    name: 'Angel Spinka',
    username: 'shalonda',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/709df1b65ad06764ee2b0edf1b49fc27?s=80\u0026d=identicon',
    web_url: 'http://192.168.1.22:3000/shalonda',
  },
  {
    id: 11,
    name: 'Art Davis',
    username: 'deja.green',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/bb56834c061522760e7a6dd7d431a306?s=80\u0026d=identicon',
    web_url: 'http://192.168.1.22:3000/deja.green',
  },
  {
    id: 32,
    name: 'Arnold Mante',
    username: 'reported_user_10',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/ab558033a82466d7905179e837d7723a?s=80\u0026d=identicon',
    web_url: 'http://192.168.1.22:3000/reported_user_10',
  },
  {
    id: 38,
    name: 'Cher Wintheiser',
    username: 'reported_user_16',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/2640356e8b5bc4314133090994ed162b?s=80\u0026d=identicon',
    web_url: 'http://192.168.1.22:3000/reported_user_16',
  },
  {
    id: 39,
    name: 'Bethel Wolf',
    username: 'reported_user_17',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/4b948694fadba4b01e4acfc06b065e8e?s=80\u0026d=identicon',
    web_url: 'http://192.168.1.22:3000/reported_user_17',
  },
];

export const branches = [
  {
    name: 'branch-1',
    commit: {
      id: '21fb056cc47dcf706670e6de635b1b326490ebdc',
      short_id: '21fb056c',
      created_at: '2020-05-07T10:58:28.000-04:00',
      parent_ids: null,
      title: 'Add new file',
      message: 'Add new file',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-05-07T10:58:28.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-05-07T10:58:28.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/21fb056cc47dcf706670e6de635b1b326490ebdc',
    },
    merged: false,
    protected: false,
    developers_can_push: false,
    developers_can_merge: false,
    can_push: true,
    default: false,
    web_url: 'http://192.168.1.22:3000/root/dag-pipeline/-/tree/branch-1',
  },
  {
    name: 'branch-10',
    commit: {
      id: '66673b07efef254dab7d537f0433a40e61cf84fe',
      short_id: '66673b07',
      created_at: '2020-03-16T11:04:46.000-04:00',
      parent_ids: null,
      title: 'Update .gitlab-ci.yml',
      message: 'Update .gitlab-ci.yml',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-03-16T11:04:46.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-03-16T11:04:46.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/66673b07efef254dab7d537f0433a40e61cf84fe',
    },
    merged: false,
    protected: false,
    developers_can_push: false,
    developers_can_merge: false,
    can_push: true,
    default: false,
    web_url: 'http://192.168.1.22:3000/root/dag-pipeline/-/tree/branch-10',
  },
  {
    name: 'branch-11',
    commit: {
      id: '66673b07efef254dab7d537f0433a40e61cf84fe',
      short_id: '66673b07',
      created_at: '2020-03-16T11:04:46.000-04:00',
      parent_ids: null,
      title: 'Update .gitlab-ci.yml',
      message: 'Update .gitlab-ci.yml',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-03-16T11:04:46.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-03-16T11:04:46.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/66673b07efef254dab7d537f0433a40e61cf84fe',
    },
    merged: false,
    protected: false,
    developers_can_push: false,
    developers_can_merge: false,
    can_push: true,
    default: false,
    web_url: 'http://192.168.1.22:3000/root/dag-pipeline/-/tree/branch-11',
  },
];

export const tags = [
  {
    name: 'tag-3',
    message: '',
    target: '66673b07efef254dab7d537f0433a40e61cf84fe',
    commit: {
      id: '66673b07efef254dab7d537f0433a40e61cf84fe',
      short_id: '66673b07',
      created_at: '2020-03-16T11:04:46.000-04:00',
      parent_ids: ['def28bf679235071140180495f25b657e2203587'],
      title: 'Update .gitlab-ci.yml',
      message: 'Update .gitlab-ci.yml',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-03-16T11:04:46.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-03-16T11:04:46.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/66673b07efef254dab7d537f0433a40e61cf84fe',
    },
    release: null,
    protected: false,
  },
  {
    name: 'tag-2',
    message: '',
    target: '66673b07efef254dab7d537f0433a40e61cf84fe',
    commit: {
      id: '66673b07efef254dab7d537f0433a40e61cf84fe',
      short_id: '66673b07',
      created_at: '2020-03-16T11:04:46.000-04:00',
      parent_ids: ['def28bf679235071140180495f25b657e2203587'],
      title: 'Update .gitlab-ci.yml',
      message: 'Update .gitlab-ci.yml',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-03-16T11:04:46.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-03-16T11:04:46.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/66673b07efef254dab7d537f0433a40e61cf84fe',
    },
    release: null,
    protected: false,
  },
  {
    name: 'tag-1',
    message: '',
    target: '66673b07efef254dab7d537f0433a40e61cf84fe',
    commit: {
      id: '66673b07efef254dab7d537f0433a40e61cf84fe',
      short_id: '66673b07',
      created_at: '2020-03-16T11:04:46.000-04:00',
      parent_ids: ['def28bf679235071140180495f25b657e2203587'],
      title: 'Update .gitlab-ci.yml',
      message: 'Update .gitlab-ci.yml',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-03-16T11:04:46.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-03-16T11:04:46.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/66673b07efef254dab7d537f0433a40e61cf84fe',
    },
    release: null,
    protected: false,
  },
  {
    name: 'master-tag',
    message: '',
    target: '66673b07efef254dab7d537f0433a40e61cf84fe',
    commit: {
      id: '66673b07efef254dab7d537f0433a40e61cf84fe',
      short_id: '66673b07',
      created_at: '2020-03-16T11:04:46.000-04:00',
      parent_ids: ['def28bf679235071140180495f25b657e2203587'],
      title: 'Update .gitlab-ci.yml',
      message: 'Update .gitlab-ci.yml',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2020-03-16T11:04:46.000-04:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2020-03-16T11:04:46.000-04:00',
      web_url:
        'http://192.168.1.22:3000/root/dag-pipeline/-/commit/66673b07efef254dab7d537f0433a40e61cf84fe',
    },
    release: null,
    protected: false,
  },
];

export const mockSearch = [
  { type: 'username', value: { data: 'root', operator: '=' } },
  { type: 'ref', value: { data: 'master', operator: '=' } },
  { type: 'status', value: { data: 'pending', operator: '=' } },
];

export const mockBranchesAfterMap = ['branch-1', 'branch-10', 'branch-11'];

export const mockTagsAfterMap = ['tag-3', 'tag-2', 'tag-1', 'master-tag'];
