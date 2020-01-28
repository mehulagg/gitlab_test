import stateFactory from '../base/state_factory';
import messages from '../../messages';

const {
  DEPENDENCY_SCANNING,
  DEPENDENCY_SCANNING_HAS_ERROR,
  DEPENDENCY_SCANNING_IS_LOADING,
} = messages;

export default stateFactory({
  feedbackPath: 'dependency_scanning',
  reportName: DEPENDENCY_SCANNING,
  errorMessage: DEPENDENCY_SCANNING_HAS_ERROR,
  loadingMessage: DEPENDENCY_SCANNING_IS_LOADING,
});
