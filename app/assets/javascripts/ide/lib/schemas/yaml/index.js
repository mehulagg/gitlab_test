import gitlabCi from './gitlab_ci';
import metricsDashboard from './metrics_dashboard';

export default {
  language: 'yaml',
  options: {
    validate: true,
    enableSchemaRequest: true,
    hover: true,
    completion: true,
    schemas: [gitlabCi, metricsDashboard],
  },
};
