import '~/pages/sessions/index';

import LengthValidator from '~/pages/sessions/new/length_validator';
import UsernameValidator from '~/pages/sessions/new/username_validator';
import NoEmojiValidator from '~/emoji/no_emoji_validator';
import SigninTabsMemoizer from '~/pages/sessions/new/signin_tabs_memoizer';
import preserveUrlFragment from '~/pages/sessions/new/preserve_url_fragment';

document.addEventListener('DOMContentLoaded', () => {
  new UsernameValidator(); // eslint-disable-line no-new
  new LengthValidator(); // eslint-disable-line no-new
  new SigninTabsMemoizer(); // eslint-disable-line no-new
  new NoEmojiValidator(); // eslint-disable-line no-new

  // Save the URL fragment from the current window location. This will be present if the user was
  // redirected to sign-in after attempting to access a protected URL that included a fragment.
  preserveUrlFragment(window.location.hash);
});
