export const mockProjectPath = 'root/autodevops-deploy';
export const mockCluster = 'production';
export const mockFiltersEndpoint = `${mockProjectPath}/logs/filters.json`;

export const mockClusters = ['production', 'staging'];

export const mockPodName = 'production-764c58d697-aaaaa';
export const mockNamespace = 'kube-system';
export const mockPods = [
  mockPodName,
  'production-764c58d697-bbbbb',
  'production-764c58d697-ccccc',
  'production-764c58d697-ddddd',
];

export const mockFilters = {
  pods: [
    {
      name: mockPods[0],
      namespace: mockNamespace,
      containers: ['first', 'second'],
    },
    {
      name: mockPods[1],
      namespace: 'gitlab-managed-apps',
      containers: ['test'],
    },
    {
      name: mockPods[2],
      namespace: 'gitlab-managed-apps',
      containers: ['test'],
    },
    {
      name: mockPods[3],
      namespace: 'gitlab-managed-apps',
      containers: ['test'],
    },
  ],
};

export const mockLines = [
  '10.36.0.1 - - [16/Oct/2019:06:29:48 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
  '10.36.0.1 - - [16/Oct/2019:06:29:57 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
  '10.36.0.1 - - [16/Oct/2019:06:29:58 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
  '10.36.0.1 - - [16/Oct/2019:06:30:07 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
  '10.36.0.1 - - [16/Oct/2019:06:30:08 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
  '10.36.0.1 - - [16/Oct/2019:06:30:17 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
  '10.36.0.1 - - [16/Oct/2019:06:30:18 UTC] "GET / HTTP/1.1" 200 13',
  '- -> /',
];
