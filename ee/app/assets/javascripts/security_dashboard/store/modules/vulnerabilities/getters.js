export default {
  dashboardError: state =>
    state.errorLoadingVulnerabilities && state.errorLoadingVulnerabilitiesCount,
  dashboardListError: state =>
    state.errorLoadingVulnerabilities && !state.errorLoadingVulnerabilitiesCount,
  dashboardCountError: state =>
    !state.errorLoadingVulnerabilities && state.errorLoadingVulnerabilitiesCount,

  getVulnerabilityHistoryByName: state => name => state.vulnerabilitiesHistory[name.toLowerCase()],

  getFilteredVulnerabilitiesHistory: (state, getters) => name => {
    const history = getters.getVulnerabilityHistoryByName(name);
    const days = state.vulnerabilitiesHistoryDayRange;

    if (!history) {
      return [];
    }

    const data = Object.entries(history);
    const currentDate = new Date();
    const startDate = new Date();

    startDate.setDate(currentDate.getDate() - days);

    return data.filter(date => {
      const parsedDate = Date.parse(date[0]);
      return parsedDate > startDate;
    });
  },
};
