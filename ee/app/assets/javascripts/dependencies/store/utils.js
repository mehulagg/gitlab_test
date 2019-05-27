export const hasDependencyList = ({ dependencies }) =>
  Array.isArray(dependencies) && dependencies.length > 0;

export const hasReportStatus = ({ report }) => Boolean(report && typeof report.status === 'string');

export const isValidResponse = ({ data }) =>
  Boolean(data && hasDependencyList(data) && hasReportStatus(data));
