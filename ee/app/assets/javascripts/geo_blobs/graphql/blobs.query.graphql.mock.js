/* eslint-disable filenames/match-regex */
import { __ } from '~/locale';

export default {
  nodes: [
    {
      id: '1',
      name: __('Uploads'),
      registry: 'upload',
      entries: {
        nodes: [
          {
            iid: '1',
            title: __('Moon.png'),
            sync_status: 'synced',
          },
          {
            iid: '2',
            title: __('vacation_beach.jpg'),
            sync_status: 'pending',
          },
          {
            iid: '3',
            title: __('blurred_image.jpeg'),
            sync_status: 'failed',
          },
        ],
      },
    },
    {
      id: '2',
      name: __('Package File'),
      registry: 'package_file',
      entries: {
        nodes: [
          {
            iid: '1',
            title: __('package.json'),
            sync_status: 'synced',
          },
          {
            iid: '2',
            title: __('package_lock.json'),
            sync_status: 'synced',
          },
          {
            iid: '3',
            title: __('yarn_lock.json'),
            sync_status: 'failed',
          },
        ],
      },
    },
    {
      id: '3',
      name: __('LFS Object'),
      registry: 'lfs_object',
      entries: {
        nodes: [
          {
            iid: '1',
            title: __('Wedding_Day.mp4'),
            sync_status: 'pending',
          },
          {
            iid: '2',
            title: __('Johnny_Cash_Greatest_Hits.mp3'),
            sync_status: 'pending',
          },
          {
            iid: '3',
            title: __('Affirmation_Statements.mp3'),
            sync_status: 'synced',
          },
        ],
      },
    },
    {
      id: '4',
      name: __('Job Artifact'),
      registry: 'job_artifact',
      entries: {
        nodes: [
          {
            iid: '1',
            title: __('Cloud_Deploy_02_11_20'),
            sync_status: 'failed',
          },
          {
            iid: '2',
            title: __('GitLab_Cache_Tomorrow'),
            sync_status: 'synced',
          },
          {
            iid: '3',
            title: __('User_Updated'),
            sync_status: 'failed',
          },
        ],
      },
    },
  ],
};
