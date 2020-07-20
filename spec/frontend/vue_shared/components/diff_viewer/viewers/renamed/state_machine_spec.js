import {
  TRANSITION_LOAD_START,
  TRANSITION_LOAD_ERROR,
  TRANSITION_LOAD_SUCCEED,
  TRANSITION_ACKNOWLEDGE_ERROR,
  STATE_IDLING,
  STATE_LOADING,
  STATE_ERRORED,
  getStateMachine,
} from '~/vue_shared/components/diff_viewer/viewers/renamed/state_machine';

describe('Renamed diff viewer state machine', () => {
  let machine;

  beforeEach(() => {
    machine = getStateMachine();
  });

  it(`starts in the "${STATE_IDLING}" state`, () => {
    expect(machine.current).toBe(STATE_IDLING);
  });

  it.each`
    state        | request      | result
    ${'idle'}    | ${'idle'}    | ${true}
    ${'idle'}    | ${'loading'} | ${false}
    ${'idle'}    | ${'errored'} | ${false}
    ${'loading'} | ${'loading'} | ${true}
    ${'loading'} | ${'idle'}    | ${false}
    ${'loading'} | ${'errored'} | ${false}
    ${'errored'} | ${'errored'} | ${true}
    ${'errored'} | ${'idle'}    | ${false}
    ${'errored'} | ${'loading'} | ${false}
  `('returns $result for "$request" when the state is "$state"', ({ request, result, state }) => {
    machine.current = state;

    expect(machine.is(request)).toBe(result);
  });

  it.each`
    state        | transition                      | result
    ${'idle'}    | ${TRANSITION_LOAD_START}        | ${STATE_LOADING}
    ${'idle'}    | ${TRANSITION_LOAD_ERROR}        | ${STATE_IDLING}
    ${'idle'}    | ${TRANSITION_LOAD_SUCCEED}      | ${STATE_IDLING}
    ${'idle'}    | ${TRANSITION_ACKNOWLEDGE_ERROR} | ${STATE_IDLING}
    ${'loading'} | ${TRANSITION_LOAD_START}        | ${STATE_LOADING}
    ${'loading'} | ${TRANSITION_LOAD_ERROR}        | ${STATE_ERRORED}
    ${'loading'} | ${TRANSITION_LOAD_SUCCEED}      | ${STATE_IDLING}
    ${'loading'} | ${TRANSITION_ACKNOWLEDGE_ERROR} | ${STATE_LOADING}
    ${'errored'} | ${TRANSITION_LOAD_START}        | ${STATE_LOADING}
    ${'errored'} | ${TRANSITION_LOAD_ERROR}        | ${STATE_ERRORED}
    ${'errored'} | ${TRANSITION_LOAD_SUCCEED}      | ${STATE_ERRORED}
    ${'errored'} | ${TRANSITION_ACKNOWLEDGE_ERROR} | ${STATE_IDLING}
  `(
    'correctly updates the state to "$result" when it starts as "$state" and the transition is "$transition"',
    ({ state, transition, result }) => {
      machine.current = state;

      machine.transition(transition);

      expect(machine.current).toEqual(result);
    },
  );
});
