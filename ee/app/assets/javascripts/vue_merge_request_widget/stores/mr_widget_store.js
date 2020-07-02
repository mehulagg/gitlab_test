import CEMergeRequestStore from '~/vue_merge_request_widget/stores/mr_widget_store';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { mapApprovalsResponse, mapApprovalRulesResponse } from '../mappers';

export default class MergeRequestStore extends CEMergeRequestStore {
  constructor(data) {
    super(data);

    this.sastHelp = data.sast_help_path;
    this.containerScanningHelp = data.container_scanning_help_path;
    this.dastHelp = data.dast_help_path;
    this.secretScanningHelp = data.secret_scanning_help_path;
    this.dependencyScanningHelp = data.dependency_scanning_help_path;
    this.vulnerabilityFeedbackPath = data.vulnerability_feedback_path;
    this.vulnerabilityFeedbackHelpPath = data.vulnerability_feedback_help_path;
    this.approvalsHelpPath = data.approvals_help_path;
    this.securityReportsPipelineId = data.pipeline_id;
    this.createVulnerabilityFeedbackIssuePath = data.create_vulnerability_feedback_issue_path;
    this.createVulnerabilityFeedbackMergeRequestPath =
      data.create_vulnerability_feedback_merge_request_path;
    this.createVulnerabilityFeedbackDismissalPath =
      data.create_vulnerability_feedback_dismissal_path;
    this.visualReviewAppAvailable = Boolean(data.visual_review_app_available);
    this.appUrl = gon && gon.gitlab_url;

    this.initPerformanceReport(data);
    this.licenseScanning = data.license_scanning;
    this.metricsReportsPath = data.metrics_reports_path;

    this.enabledReports = convertObjectPropsToCamelCase(data.enabled_reports);

    this.blockingMergeRequests = data.blocking_merge_requests;

    this.hasApprovalsAvailable = data.has_approvals_available;
    this.apiApprovalsPath = data.api_approvals_path;
    this.apiApprovalSettingsPath = data.api_approval_settings_path;
    this.apiApprovePath = data.api_approve_path;
    this.apiUnapprovePath = data.api_unapprove_path;
  }

  setData(data, isRebased) {
    this.initGeo(data);
    this.initApprovals();

    this.mergePipelinesEnabled = Boolean(data.merge_pipelines_enabled);
    this.mergeTrainsCount = data.merge_trains_count || 0;
    this.mergeTrainIndex = data.merge_train_index;

    super.setData(data, isRebased);
  }

  initGeo(data) {
    this.isGeoSecondaryNode = this.isGeoSecondaryNode || data.is_geo_secondary_node;
    this.geoSecondaryHelpPath = this.geoSecondaryHelpPath || data.geo_secondary_help_path;
  }

  initApprovals() {
    this.isApproved = this.isApproved || false;
    this.approvals = this.approvals || null;
    this.approvalRules = this.approvalRules || [];
  }

  setApprovals(data) {
    this.approvals = mapApprovalsResponse(data);
    this.approvalsLeft = Boolean(data.approvals_left);
    this.isApproved = data.approved || false;
    this.preventMerge = !this.isApproved;
  }

  setApprovalRules(data) {
    this.approvalRules = mapApprovalRulesResponse(data.rules, this.approvals);
  }

  initPerformanceReport(data) {
    this.performance = data.performance;
    this.performanceMetrics = {
      improved: [],
      degraded: [],
    };
  }

  comparePerformanceMetrics(headMetrics, baseMetrics) {
    const headMetricsIndexed = MergeRequestStore.normalizePerformanceMetrics(headMetrics);
    const baseMetricsIndexed = MergeRequestStore.normalizePerformanceMetrics(baseMetrics);
    const improved = [];
    const degraded = [];

    Object.keys(headMetricsIndexed).forEach(subject => {
      const subjectMetrics = headMetricsIndexed[subject];
      Object.keys(subjectMetrics).forEach(metric => {
        const headMetricData = subjectMetrics[metric];

        if (baseMetricsIndexed[subject] && baseMetricsIndexed[subject][metric]) {
          const baseMetricData = baseMetricsIndexed[subject][metric];
          const metricData = {
            name: metric,
            path: subject,
            score: headMetricData.value,
            delta: headMetricData.value - baseMetricData.value,
          };

          if (metricData.delta !== 0) {
            const isImproved =
              headMetricData.desiredSize === 'smaller'
                ? metricData.delta < 0
                : metricData.delta > 0;

            if (isImproved) {
              improved.push(metricData);
            } else {
              degraded.push(metricData);
            }
          }
        }
      });
    });

    this.performanceMetrics = { improved, degraded };
  }

  // normalize performance metrics by indexing on performance subject and metric name
  static normalizePerformanceMetrics(performanceData) {
    const indexedSubjects = {};
    performanceData.forEach(({ subject, metrics }) => {
      const indexedMetrics = {};
      metrics.forEach(({ name, ...data }) => {
        indexedMetrics[name] = data;
      });
      indexedSubjects[subject] = indexedMetrics;
    });

    return indexedSubjects;
  }
}
