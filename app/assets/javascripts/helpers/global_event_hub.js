import eventHubFactory from '~/helpers/event_hub_factory';

/**
 * Sometimes old code needs to communicate with new Vue code, for this
 * reason we use a global event hub rather than to abuse the document Event
 * space because it is decoupled from DOM events and event bubbling.
 *
 * It is supposed to be a replacement for jQuery:
 *     $(document).on() // with non-DOM events
 */
const globalHub = eventHubFactory();

/**
 * This event is used to update the toggle count in the nav bar
 */
export const TODO_TOGGLE = 'todo:toggle';

export const globalEmit = (...args) => {
  globalHub.$emit(...args);
};
export const globalOn = (...args) => {
  globalHub.$on(...args);
};
