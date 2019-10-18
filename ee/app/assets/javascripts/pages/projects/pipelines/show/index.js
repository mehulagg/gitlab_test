import initPipelineDetails from '~/pipelines/pipeline_details_bundle';
import initPipelines from '~/pages/projects/pipelines/init_pipelines';
import initPipelineSecurityDashboard from 'ee/security_dashboard/pipeline_index';
import initLicenseReport from './license_report';

document.addEventListener('DOMContentLoaded', () => {
  initPipelines();
  initPipelineDetails();
  initPipelineSecurityDashboard();
  initLicenseReport();
});
