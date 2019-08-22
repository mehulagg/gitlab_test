# Updating the Geo nodes **(PREMIUM ONLY)**

Some versions require addition steps during update, so please consult
the [version specific update steps](#version-specific-update-steps)
before you proceed with the [general update steps](#general-update-steps).

## Version specific update steps

Depending on which version of Geo you are updating to/from, there may be
different steps.

- [Updating to GitLab 12.1](version_specific_updates.md#updating-to-gitlab-121)
- [Updating to GitLab 10.8](version_specific_updates.md#updating-to-gitlab-108)
- [Updating to GitLab 10.6](version_specific_updates.md#updating-to-gitlab-106)
- [Updating to GitLab 10.5](version_specific_updates.md#updating-to-gitlab-105)
- [Updating to GitLab 10.4](version_specific_updates.md#updating-to-gitlab-104)
- [Updating to GitLab 10.3](version_specific_updates.md#updating-to-gitlab-103)
- [Updating to GitLab 10.2](version_specific_updates.md#updating-to-gitlab-102)
- [Updating to GitLab 10.1](version_specific_updates.md#updating-to-gitlab-101)
- [Updating to GitLab 10.0](version_specific_updates.md#updating-to-gitlab-100)
- [Updating from GitLab 9.3 or older](version_specific_updates.md#updating-from-gitlab-93-or-older)
- [Updating to GitLab 9.0](version_specific_updates.md#updating-to-gitlab-90)

## General update steps

In order to update the Geo nodes when a new GitLab version is released,
all you need to do is update GitLab itself:

1. Log into each node (**primary** and **secondary** nodes).
1. [Update GitLab][../../../update/README.md].
1. [Test](#check-status-after-updating) **primary** and **secondary** nodes, and check version in each.

### Check status after updating

Now that the update process is complete, you may want to check whether
everything is working correctly:

1. Run the Geo raketask on all nodes, everything should be green:

   ```sh
   sudo gitlab-rake gitlab:geo:check
   ```

1. Check the **primary** node's Geo dashboard for any errors.
1. Test the data replication by pushing code to the **primary** node and see if it
   is received by **secondary** nodes.
