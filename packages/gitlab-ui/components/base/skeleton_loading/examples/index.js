import SkeletonLoadingBasicExample from './skeleton-loading.basic.example.vue';
import SkeletonLoadingOneLineExample from './skeleton-loading.one-line.example.vue';

export default [
  {
    name: 'Basic',
    items: [
      {
        id: 'skeleton-loader-basic',
        name: 'Basic',
        description: 'Basic Skeleton Loader',
        component: SkeletonLoadingBasicExample,
      },
      {
        id: 'skeleton-loader-single-line',
        name: 'One Line',
        description: 'Skeleton Loader with one line',
        component: SkeletonLoadingOneLineExample,
      },
    ],
  },
];
