import { REPORT_STATUS } from './constants';

export const jobNotSetUp = state => state.report.status === REPORT_STATUS.jobNotSetUp;
export const jobFailed = state => state.report.status === REPORT_STATUS.jobFailed;
export const isIncomplete = state => state.report.status === REPORT_STATUS.incomplete;
