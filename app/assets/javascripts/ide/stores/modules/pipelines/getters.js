import { states } from './constants';

export default {
  hasLatestPipeline: state => !state.isLoadingPipeline && !!state.latestPipeline,

  pipelineFailed: state =>
    state.latestPipeline && state.latestPipeline.details.status.text === states.failed,

  failedStages: state =>
    state.stages
      .filter(stage => stage.status.text.toLowerCase() === states.failed)
      .map(stage => ({
        ...stage,
        jobs: stage.jobs.filter(job => job.status.text.toLowerCase() === states.failed),
      })),

  failedJobsCount: state =>
    state.stages.reduce(
      (acc, stage) => acc + stage.jobs.filter(j => j.status.text === states.failed).length,
      0,
    ),

  jobsCount: state => state.stages.reduce((acc, stage) => acc + stage.jobs.length, 0),
};
