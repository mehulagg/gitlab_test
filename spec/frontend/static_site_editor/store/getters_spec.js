import createState from '~/static_site_editor/store/state';
import { isLoadingContent, isContentLoaded } from '~/static_site_editor/store/getters';
import { LOADING, LOADED } from '~/static_site_editor/constants';

describe('Static Site Editor Store getters', () => {
  it.each`
    getter                | getterFn            | status
    ${'isLoadingContent'} | ${isLoadingContent} | ${LOADING}
    ${'isContentLoaded'}  | ${isContentLoaded}  | ${LOADED}
  `('$getter returns true when state is $state', ({ getterFn, status }) => {
    const state = createState({ status });

    expect(getterFn(state)).toBe(true);
  });
});
