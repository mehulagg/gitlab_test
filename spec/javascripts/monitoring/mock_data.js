import {
  // data imported from jest tests gets re-exported
  deploymentData as importedDeploymentData,
  anomalyMockGraphData as importedAnomalyMockGraphData,
  graphDataPrometheusQuery as importedGraphDataPrometheusQuery,
  metricsGroupsAPIResponse as importedMetricsGroupsAPIResponse,
} from '../../frontend/monitoring/mock_data';

export const anomalyMockGraphData = importedAnomalyMockGraphData;
export const graphDataPrometheusQuery = importedGraphDataPrometheusQuery;
export const deploymentData = importedDeploymentData;
export const metricsGroupsAPIResponse = importedMetricsGroupsAPIResponse;

export const mockApiEndpoint = `${gl.TEST_HOST}/monitoring/mock`;
export const mockProjectPath = '/frontend-fixtures/environments-project';

export default metricsGroupsAPIResponse;

export const singleGroupResponse = [
  {
    group: 'System metrics (Kubernetes)',
    priority: 5,
    metrics: [
      {
        title: 'Memory Usage (Total)',
        weight: 0,
        y_label: 'Total Memory Used',
        queries: [
          {
            query_range:
              'avg(sum(container_memory_usage_bytes{container_name!="POD",pod_name=~"^production-(.*)",namespace="autodevops-deploy-33"}) by (job)) without (job)  /1024/1024/1024',
            unit: 'GB',
            label: 'Total',
            result: [
              {
                metric: {},
                values: [
                  [1558453960.079, '0.0357666015625'],
                  [1558454020.079, '0.035675048828125'],
                  [1558454080.079, '0.035152435302734375'],
                  [1558454140.079, '0.035221099853515625'],
                  [1558454200.079, '0.0352325439453125'],
                  [1558454260.079, '0.03479766845703125'],
                  [1558454320.079, '0.034793853759765625'],
                  [1558454380.079, '0.034931182861328125'],
                  [1558454440.079, '0.034816741943359375'],
                  [1558454500.079, '0.034816741943359375'],
                  [1558454560.079, '0.034816741943359375'],
                ],
              },
            ],
          },
        ],
        id: 15,
      },
    ],
  },
];

export const statePaths = {
  settingsPath: '/root/hello-prometheus/services/prometheus/edit',
  clustersPath: '/root/hello-prometheus/clusters',
  documentationPath: '/help/administration/monitoring/prometheus/index.md',
};

export const queryWithoutData = {
  title: 'HTTP Error rate',
  weight: 10,
  y_label: 'Http Error Rate',
  queries: [
    {
      query_range:
        'sum(rate(nginx_upstream_responses_total{status_code="5xx", upstream=~"nginx-test-8691397-production-.*"}[2m])) / sum(rate(nginx_upstream_responses_total{upstream=~"nginx-test-8691397-production-.*"}[2m])) * 100',
      label: '5xx errors',
      unit: '%',
      result: [],
    },
  ],
};

export function convertDatesMultipleSeries(multipleSeries) {
  const convertedMultiple = multipleSeries;
  multipleSeries.forEach((column, index) => {
    let convertedResult = [];
    convertedResult = column.queries[0].result.map(resultObj => {
      const convertedMetrics = {};
      convertedMetrics.values = resultObj.values.map(val => ({
        time: new Date(val.time),
        value: val.value,
      }));
      convertedMetrics.metric = resultObj.metric;
      return convertedMetrics;
    });
    convertedMultiple[index].queries[0].result = convertedResult;
  });
  return convertedMultiple;
}

export const environmentData = [
  {
    id: 34,
    name: 'production',
    state: 'available',
    external_url: 'http://root-autodevops-deploy.my-fake-domain.com',
    environment_type: null,
    stop_action: false,
    metrics_path: '/root/hello-prometheus/environments/34/metrics',
    environment_path: '/root/hello-prometheus/environments/34',
    stop_path: '/root/hello-prometheus/environments/34/stop',
    terminal_path: '/root/hello-prometheus/environments/34/terminal',
    folder_path: '/root/hello-prometheus/environments/folders/production',
    created_at: '2018-06-29T16:53:38.301Z',
    updated_at: '2018-06-29T16:57:09.825Z',
    last_deployment: {
      id: 127,
    },
  },
  {
    id: 35,
    name: 'review/noop-branch',
    state: 'available',
    external_url: 'http://root-autodevops-deploy-review-noop-branc-die93w.my-fake-domain.com',
    environment_type: 'review',
    stop_action: true,
    metrics_path: '/root/hello-prometheus/environments/35/metrics',
    environment_path: '/root/hello-prometheus/environments/35',
    stop_path: '/root/hello-prometheus/environments/35/stop',
    terminal_path: '/root/hello-prometheus/environments/35/terminal',
    folder_path: '/root/hello-prometheus/environments/folders/review',
    created_at: '2018-07-03T18:39:41.702Z',
    updated_at: '2018-07-03T18:44:54.010Z',
    last_deployment: {
      id: 128,
    },
  },
  {
    id: 36,
    name: 'no-deployment/noop-branch',
    state: 'available',
    created_at: '2018-07-04T18:39:41.702Z',
    updated_at: '2018-07-04T18:44:54.010Z',
  },
];

export const metricsDashboardResponse = {
  dashboard: {
    dashboard: 'Environment metrics',
    priority: 1,
    panel_groups: [
      {
        group: 'System metrics (Kubernetes)',
        priority: 5,
        panels: [
          {
            title: 'Memory Usage (Total)',
            type: 'area-chart',
            y_label: 'Total Memory Used',
            weight: 4,
            metrics: [
              {
                id: 'system_metrics_kubernetes_container_memory_total',
                query_range:
                  'avg(sum(container_memory_usage_bytes{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}) by (job)) without (job)  /1024/1024/1024',
                label: 'Total',
                unit: 'GB',
                metric_id: 12,
                prometheus_endpoint_path: 'http://test',
              },
            ],
          },
          {
            title: 'Core Usage (Total)',
            type: 'area-chart',
            y_label: 'Total Cores',
            weight: 3,
            metrics: [
              {
                id: 'system_metrics_kubernetes_container_cores_total',
                query_range:
                  'avg(sum(rate(container_cpu_usage_seconds_total{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}[15m])) by (job)) without (job)',
                label: 'Total',
                unit: 'cores',
                metric_id: 13,
              },
            ],
          },
          {
            title: 'Memory Usage (Pod average)',
            type: 'line-chart',
            y_label: 'Memory Used per Pod',
            weight: 2,
            metrics: [
              {
                id: 'system_metrics_kubernetes_container_memory_average',
                query_range:
                  'avg(sum(container_memory_usage_bytes{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}) by (job)) without (job) / count(avg(container_memory_usage_bytes{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}) without (job)) /1024/1024',
                label: 'Pod average',
                unit: 'MB',
                metric_id: 14,
              },
            ],
          },
        ],
      },
    ],
  },
  status: 'success',
};

export const dashboardGitResponse = [
  {
    path: 'config/prometheus/common_metrics.yml',
    display_name: 'Common Metrics',
    default: true,
  },
  {
    path: '.gitlab/dashboards/super.yml',
    display_name: 'Custom Dashboard 1',
    default: false,
  },
];

export const graphDataPrometheusQueryRange = {
  title: 'Super Chart A1',
  type: 'area-chart',
  weight: 2,
  metrics: [
    {
      id: 'metric_a1',
      metric_id: 2,
      query_range:
        'avg(sum(container_memory_usage_bytes{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}) by (job)) without (job)  /1024/1024/1024',
      unit: 'MB',
      label: 'Total Consumption',
      prometheus_endpoint_path:
        '/root/kubernetes-gke-project/environments/35/prometheus/api/v1/query?query=max%28go_memstats_alloc_bytes%7Bjob%3D%22prometheus%22%7D%29+by+%28job%29+%2F1024%2F1024',
    },
  ],
  queries: [
    {
      metricId: null,
      id: 'metric_a1',
      metric_id: 2,
      query_range:
        'avg(sum(container_memory_usage_bytes{container_name!="POD",pod_name=~"^%{ci_environment_slug}-(.*)",namespace="%{kube_namespace}"}) by (job)) without (job)  /1024/1024/1024',
      unit: 'MB',
      label: 'Total Consumption',
      prometheus_endpoint_path:
        '/root/kubernetes-gke-project/environments/35/prometheus/api/v1/query?query=max%28go_memstats_alloc_bytes%7Bjob%3D%22prometheus%22%7D%29+by+%28job%29+%2F1024%2F1024',
      result: [
        {
          metric: {},
          values: [[1495700554.925, '8.0390625'], [1495700614.925, '8.0390625']],
        },
      ],
    },
  ],
};
