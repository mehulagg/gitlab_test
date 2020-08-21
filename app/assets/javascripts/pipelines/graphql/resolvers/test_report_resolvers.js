const resolvers = {
  TestReports: {
    testReport: () => ({
      total: () => ({
        time: 3.205999999999997,
        count: 4,
        success: 4,
        failed: 0,
        skipped: 0,
        error: 0,
      }),
      testSuites: () => ([{
        name: 'jest',
        total: () => ({
          time: 5,
          count: 4,
          success: 4,
          failed: 0,
          skipped: 0,
          error: 0,
        }),
        build_ids: () => ([692476931]),
        suiteError: null,
        testCases: () => ([
          {
            status: 'success',
            name: 'testing',
            className: 'jesting',
            execution_time: 1.25,
            system_output: null,
            stack_trace: null,
          },
          {
            status: 'success',
            name: 'testing',
            className: 'jesting',
            execution_time: 1.25,
            system_output: null,
            stack_trace: null,
          },
          {
            status: 'success',
            name: 'testing',
            className: 'jesting',
            execution_time: 1.25,
            system_output: null,
            stack_trace: null,
          },
          {
            status: 'success',
            name: 'testing',
            className: 'jesting',
            execution_time: 1.25,
            system_output: null,
            stack_trace: null,
          },
        ]),
      }]),
    })
  }
};

export default resolvers;
