---
description: 'Step-by-step use case overview'
---

# Set up a SSH key for GitLab

This procedure refers to detailed information in our [GitLab and SSH keys](README.md) document. The steps in the following procedure are "bare-bones"; they include references to the noted document if you need more detail.

To set up a secure SSH-based connection to GitLab, take the following steps:

1. Create a secure [ED25519](README.md#options-for-ssh-keys). Substitute your email address for `<comment>`:

   ```shell
   ssh-keygen -t ed25519 -C "<comment>"
   ```

1. Unless you have an existing `id_ed25519` key in your `~/.ssh` directory, accept the defaults.
1. Copy the contents of your public key, in the `id_ed25519.pub` file, to your clipboard.
1. Navigate to `http://gitlab.com` and sign in.
1. Select your avatar in the upper right corner, and click **Settings**
1. Click **SSH Keys**.
1. Paste the contents of the public key that you copied into the **Key** text box.
1. Make sure your key includes a descriptive name in the **Title** text box.
1. Include an (optional) expiry date for the key under "Expires at" section. (Introduced in [GitLab 12.9](https://gitlab.com/gitlab-org/gitlab/-/issues/36243).)
1. Click the **Add key** button.
1. [Test the result](README.md#testing-that-everything-is-set-up-correctly) with the following command:

```shell
ssh -T git@gitlab.com
```
