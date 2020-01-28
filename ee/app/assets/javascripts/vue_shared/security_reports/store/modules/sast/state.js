import stateFactory from '../base/state_factory';
import messages from '../../messages';

const { SAST } = messages;

export default stateFactory({
  feedbackPathCategory: 'sast',
  reportType: SAST,
});
