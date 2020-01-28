import stateFactory from '../base/state_factory';
import messages from '../../messages';

const {
  CONTAINER_SCANNING,
  CONTAINER_SCANNING_HAS_ERROR,
  CONTAINER_SCANNING_IS_LOADING,
} = messages;

export default stateFactory({
  feedbackPath: 'container_scanning',
  reportName: CONTAINER_SCANNING,
  errorMessage: CONTAINER_SCANNING_HAS_ERROR,
  loadingMessage: CONTAINER_SCANNING_IS_LOADING,
});
