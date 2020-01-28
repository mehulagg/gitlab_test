import Vue from 'vue';

import UsersCache from './lib/utils/users_cache';
import UserPopover from './vue_shared/components/user_popover/user_popover.vue';

/**
 * Adds a UserPopover component to the body, hands over as much data as the target element has in data attributes.
 * loads based on data-user-id more data about a user from the API and sets it on the popover
 */
const loadUserData = (user, target) => {
  // Add listener to actually remove it again
  const { dataset } = target;

  // Helps us to use current markdown setup without maybe breaking or duplicating for now
  if (dataset.user) {
    dataset.userId = dataset.user;
    // Removing titles so its not showing tooltips also
    dataset.originalTitle = '';
    target.setAttribute('title', '');
  }

  const { userId, username, name, avatarUrl } = dataset;

  Object.assign(user, {
    userId,
    username,
    name,
    avatarUrl,
  });

  if (userId || username) {
    return UsersCache.retrieveById(userId)
      .then(userData => {
        if (!userData) {
          return undefined;
        }

        Object.assign(user, {
          avatarUrl: userData.avatar_url,
          username: userData.username,
          name: userData.name,
          location: userData.location,
          bio: userData.bio,
          organization: userData.organization,
          status: userData.status,
          loaded: true,
        });

        if (userData.status) {
          return null;
        }

        return UsersCache.retrieveStatusById(userId);
      })
      .then(status => {
        if (!status) {
          return;
        }

        Object.assign(user, {
          status,
        });
      });
  }

  return null;
};

export default elements => {
  const userLinks = elements || [...document.querySelectorAll('.js-user-link')];

  userLinks.forEach(el => {
    const UserPopoverComponent = Vue.extend(UserPopover);
    const user = {
      location: null,
      bio: null,
      organization: null,
      status: null,
      loaded: false,
    };

    const renderedPopover = new UserPopoverComponent({
      propsData: {
        target: el,
        user,
      },
    });

    renderedPopover.$on('show', () => loadUserData(user, el));
    renderedPopover.$mount();
  });
};
