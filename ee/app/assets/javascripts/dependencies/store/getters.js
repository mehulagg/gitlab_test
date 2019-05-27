import { REPORT_STATUS } from './constants';

// TODO: Give these more explicit names, e.g., dependencyListJobNotSetUp
export const jobNotSetUp = state => state.reportInfo.status === REPORT_STATUS.jobNotSetUp;
export const jobFailed = state => state.reportInfo.status === REPORT_STATUS.jobFailed;
export const isIncomplete = state => state.reportInfo.status === REPORT_STATUS.incomplete;
