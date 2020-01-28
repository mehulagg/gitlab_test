import stateFactory from '../base/state_factory';
import messages from '../../messages';

const { DEPENDENCY_SCANNING } = messages;

export default stateFactory({
  feedbackPathCategory: 'dependency_scanning',
  reportType: DEPENDENCY_SCANNING,
});
