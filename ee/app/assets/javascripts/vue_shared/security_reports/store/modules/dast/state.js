import stateFactory from '../base/state_factory';
import messages from '../../messages';

const { DAST } = messages;

export default stateFactory({
  feedbackPathCategory: 'dast',
  reportType: DAST,
});
