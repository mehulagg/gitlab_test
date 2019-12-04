export const mockProjectPath = 'root/autodevops-deploy';
export const mockEnvName = 'production';
export const mockEnvironmentsEndpoint = `${mockProjectPath}/environments.json`;

export const mockPodName = 'production-764c58d697-aaaaa';
export const mockPods = [
  mockPodName,
  'production-764c58d697-bbbbb',
  'production-764c58d697-ccccc',
  'production-764c58d697-ddddd',
];

const makeMockEnvironment = (name, mockPods) => ({
  name,
  namespace: 'foo',
  es_enabled: true,
  pods: mockPods.map(name => {
    return { name: name };
  }),
});

export const mockEnvironment = makeMockEnvironment(mockEnvName, mockPods);
export const mockEnvironments = [
  mockEnvironment,
  makeMockEnvironment('staging', mockPods),
  makeMockEnvironment('review/a-feature', mockPods),
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
