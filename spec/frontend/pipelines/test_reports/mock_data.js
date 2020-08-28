import { TestStatus } from '~/pipelines/constants';

export const skippedTestCases = [
  {
    classname: 'spec.test_spec',
    execution_time: 0,
    name: 'Test#skipped text',
    stack_trace: null,
    status: TestStatus.SKIPPED,
    system_output: null,
  },
];

export const erroredTestCases = [
  {
    classname: 'spec.test_spec',
    execution_time: 0,
    name: 'Test#errored text',
    stack_trace: null,
    status: TestStatus.ERRORED,
    system_output: null,
  },
];
