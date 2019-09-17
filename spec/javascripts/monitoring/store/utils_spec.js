import { groupQueriesByChartInfo, normalizeMetric } from '~/monitoring/stores/utils';

describe('groupQueriesByChartInfo', () => {
  let input;
  let output;

  it('groups metrics with the same chart title and y_axis label', () => {
    input = [
      { title: 'title', y_label: 'MB', queries: [{}] },
      { title: 'title', y_label: 'MB', queries: [{}] },
      { title: 'new title', y_label: 'MB', queries: [{}] },
    ];

    output = [
      {
        title: 'title',
        y_label: 'MB',
        queries: [{ metricId: undefined }, { metricId: undefined }],
      },
      { title: 'new title', y_label: 'MB', queries: [{ metricId: undefined }] },
    ];

    expect(groupQueriesByChartInfo(input)).toEqual(output);
  });

  // Functionality associated with the /additional_metrics endpoint
  it("associates a chart's stringified metric_id with the metric", () => {
    input = [{ metric_id: 'undefined_3', title: 'new title', y_label: 'MB', queries: [{}] }];
    output = [
      {
        metric_id: 'undefined_3',
        title: 'new title',
        y_label: 'MB',
        queries: [{ metricId: undefined }],
      },
    ];

    expect(groupQueriesByChartInfo(input)).toEqual(output);
  });

  // Functionality associated with the /metrics_dashboard endpoint
  it('aliases a stringified metrics_id on the metric to the metricId key', () => {
    input = [{ title: 'new title', y_label: 'MB', queries: [{ metric_id: 3 }] }];
    output = [{ title: 'new title', y_label: 'MB', queries: [{ metricId: '3', metric_id: 3 }] }];

    expect(groupQueriesByChartInfo(input)).toEqual(output);
  });
});

describe('normalizeMetric', () => {
  [
    { args: [], expected: 'undefined_undefined' },
    { args: [undefined], expected: 'undefined_undefined' },
    { args: [{ id: 'something' }], expected: 'undefined_something' },
    { args: [{ id: 45 }], expected: 'undefined_45' },
    { args: [{ metric_id: 5 }], expected: '5_undefined' },
    { args: [{ metric_id: 'something' }], expected: 'something_undefined' },
    {
      args: [{ metric_id: 5, id: 'system_metrics_kubernetes_container_memory_total' }],
      expected: '5_system_metrics_kubernetes_container_memory_total',
    },
  ].forEach(({ args, expected }) => {
    it(`normalizes metric to "${expected}" with args=${JSON.stringify(args)}`, () => {
      expect(normalizeMetric(...args)).toEqual({ metric_id: expected });
    });
  });
});
