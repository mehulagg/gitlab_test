export const displayChart = state =>
  Boolean(!state.isLoading && state.config?.chart?.series?.length);

export const chartYAxisTitle = state => state?.config?.chart?.series[0]?.title || '';
