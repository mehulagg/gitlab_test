import { LOADING, ERROR, SUCCESS } from '../constants';

export default {
  summaryStatus: state => {
    if (state.isLoading) {
      return LOADING;
    }

    if (state.hasError || state.numberOfChanges > 0) {
      return ERROR;
    }

    return SUCCESS;
  },

  metrics: state => [
    ...state.newMetrics.map(metric => ({ ...metric, isNew: true })),
    ...state.existingMetrics,
    ...state.removedMetrics.map(metric => ({ ...metric, wasRemoved: true })),
  ],
};
