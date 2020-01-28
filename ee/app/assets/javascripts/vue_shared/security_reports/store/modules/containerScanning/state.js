import stateFactory from '../base/state_factory';
import messages from '../../messages';

const { CONTAINER_SCANNING } = messages;

export default stateFactory({
  feedbackPathCategory: 'container_scanning',
  reportType: CONTAINER_SCANNING,
});
