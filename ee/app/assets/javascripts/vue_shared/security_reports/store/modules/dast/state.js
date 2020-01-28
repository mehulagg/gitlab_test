import stateFactory from '../base/state_factory';
import messages from '../../messages';

const { DAST, DAST_HAS_ERROR, DAST_IS_LOADING } = messages;

export default stateFactory({
  feedbackPath: 'dast',
  reportName: DAST,
  errorMessage: DAST_HAS_ERROR,
  loadingMessage: DAST_IS_LOADING,
});
