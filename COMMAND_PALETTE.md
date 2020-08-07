actions:

## Requirements

* Has global actions
* route/state specific actions can be added with plain JS
* Documented requirements for actions
* Action that requires Axios call
* Action that requires Apollo call

Merge merge request
Assign user
Go to settings (global)
Go to diffs (only MR)
Turn off command palette
Add label

## Should this support multiple commands at once?

### cons

* Makes for some interesting race conditions

### pros

* Users are used to this from quick actions


## Notes

Need to expose search_box_by_click icon if we want to reuse search box.

Good to reuse search tokens since this is a known UX component for the user.

Need to verify that passing in `token`s ala FilteredSearch isn't a large memory drain.

Look into using Vuex store for stored commands. This way we won't need to address a race-condition of mounting command_palette app and components registering actions in their mount: Would be cool to have a Jest spec that covers this.

Might be worth putting mounting of the command palette behind a keyevent. It'll be slower to show up when invoked, but most people won't be invoking it, and even then it'll be on a sub-set of pages.
