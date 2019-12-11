export const mockProjectPath = 'root/autodevops-deploy';
export const mockEnvName = 'production';
export const mockPodName = 'production-764c58d697-aaaaa';
export const mockEnvironmentsEndpoint = `${mockProjectPath}/environments.json`;

const makeMockPods = (name, env) => [
  { name, containers: [] },
  { name: `${env}-764c58d697-bbbbb`, containers: [] },
  { name: `${env}-764c58d697-ccccc`, containers: [] },
  { name: `${env}-764c58d697-ddddd`, containers: [] },
];

const makeMockEnvironment = name => ({
  name,
  namespace: 'foo',
  es_enabled: true,
  pods: makeMockPods(mockPodName, name),
});

export const mockPods = makeMockPods(mockPodName, mockEnvName);

export const mockEnvironment = makeMockEnvironment(mockEnvName, mockPods);
export const mockEnvironments = [
  mockEnvironment,
  makeMockEnvironment('staging'),
  makeMockEnvironment('review/a-feature'),
];

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
