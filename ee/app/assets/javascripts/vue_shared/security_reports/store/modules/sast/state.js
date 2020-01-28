import stateFactory from '../base/state_factory';
import messages from '../../messages';

const { SAST, SAST_HAS_ERROR, SAST_IS_LOADING } = messages;

export default stateFactory({
  feedbackPath: 'sast',
  reportName: SAST,
  errorMessage: SAST_HAS_ERROR,
  loadingMessage: SAST_IS_LOADING,
});
