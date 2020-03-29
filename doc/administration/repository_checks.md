# Repository checks

> [Introduced][ce-3232] in GitLab 8.7.

Git has a built-in mechanism, [`git fsck`][git-fsck], to verify the
integrity of all data committed to a repository. GitLab administrators
can trigger such a check for a project via the project page under the
admin panel. The checks run asynchronously so it may take a few minutes
before the check result is visible on the project admin page. If the
checks failed you can see their output on the admin log page under
'repocheck.log'.

NOTE: **Note:**
It is OFF by default because it still causes too many false alarms.

## Periodic checks

When enabled, GitLab periodically runs a repository check on all project
repositories and wiki repositories in order to detect data corruption.
A project will be checked no more than once per month. If any projects
fail their repository checks all GitLab administrators will receive an email
notification of the situation. This notification is sent out once a week,
by default, midnight at the start of Sunday. Repositories with known check
failures can be found at `/admin/projects?last_repository_check_failed=1`.

## Disabling periodic checks

You can disable the periodic checks on the 'Settings' page of the admin
panel.

## What to do if a check failed

If the repository check fails for some repository you should look up the error
in `repocheck.log`:

- in the [admin panel](logs.md#repochecklog)
- or on disk, see:
  - `/var/log/gitlab/gitlab-rails` for Omnibus installations
  - `/home/git/gitlab/log` for installations from source

If the periodic repository check causes false alarms, you can clear all repository check states by
navigating to **Admin Area > Settings > Repository**
(`/admin/application_settings/repository`) and clicking **Clear all repository checks**.

### How to fix a corrupted repository in your GitLab instance

Since `git` is decentralized, as long as one of the GitLab users have a working copy,
you can still try to fix a corrupted repository in your GitLab instance.

For example, consider that the working repository is in a local directory
`/home/user/group01/project01` and the corrupted repository is in `https://gitlab.com/group01/project01`:

#### From a working copy of your repository

You can try the following steps to try to restore a corrupted repository.
You'll need a non-corrupted local copy of the repository and Admin access to GitLab Rails console.

1. Go to your instance's **{admin}** **Admin Area > Overview > Projects** and click **Trigger repository check**.
   This generates a `repocheck.log` under the `/var/log/gitlab/gitlab-rails/` directory.

1. Check the `repocheck.log`:

   ```shell
   cat /var/log/gitlab/gitlab-rails/repocheck.log
   ```

   Output:

   ```shell
   # Logfile created on 2020-03-29 08:22:37 +0000 by logger.rb/66358
   E, [2020-03-29T08:22:37.545837 #25336] ERROR -- : Could not fsck repository: broken link from    tree 72fdee8b9f68d47390f2ada605905be17f08c764
                 to    blob bbe52438cc34bddf2ca127d7d6275fd38e4831c6
   broken link from    tree 60ea493d20e198c26dcea1f577c33ace3fdcc6de
                 to    blob db2b9e39b032cfac540413413c6186bde026636f
   missing blob db2b9e39b032cfac540413413c6186bde026636f
   missing blob bbe52438cc34bddf2ca127d7d6275fd38e4831c6
   ```

1. Get the missing objects from `repocheck.log`:

   ```shell
   grep missing /var/log/gitlab/gitlab-rails/repocheck.log | cut -d " " -f 3 | tee /tmp/missing-objects.txt
   ```

   Output:

   ```shell
   db2b9e39b032cfac540413413c6186bde026636f
   bbe52438cc34bddf2ca127d7d6275fd38e4831c6
   ```

1. Run the following commannds on a machine that has an uncorrupted copy of the repository:

   ```shell
   scp root@remote-server:/tmp/missing-objects.txt /tmp/missing-objects.txt
   cd /home/user/group01/project01
   git pack-objects /tmp/missing-objects < /tmp/missing-objects.txt
   ```

   Output:

   ```shell
   Enumerating objects: 2, done.
   Counting objects: 100% (2/2), done.
   Delta compression using up to 16 threads
   Compressing objects: 100% (2/2), done.
   db51c8f86eb8f4338b9a3ecd3b637b02a721e7cd
   Writing objects: 100% (2/2), done.
   Total 2 (delta 0), reused 1 (delta 0), pack-reused 0
   ```

   This creates a file named `/tmp/missing-objects-<sha256sum>.pack`.

1. Transfer the generated file to the Gitaly server:

   ```shell
   scp root@remote-server:/tmp/missing-objects-<sha256sum>.pack /tmp/missing-objects-<sha256sum>.pack
   ```

1. Run the command on the Gitaly server:

   ```shell
   ## First we enter the GitLab Rails console to try to get the local repository
   sudo gitlab-rails console
   ```

   While inside the Rails console:

   ```shell
   ## Replace <PROJECT_ID> with the actual project ID.
   irb(main):001:0> puts Project.find(<PROJECT_ID>).repository.path
   ```

   Output:

   ```shell
   /var/opt/gitlab/git-data/repositories/@hashed/6f/4b/6f4b6612125fb3a0daecd2799dfd6c9c299424fd920f9b308110a2c1fbd8f443.git
   => nil
   ```

   Take note of the full repository path. Then type the following commands:

   1. Login as the Git user

   ```shell
   sudo -i -u git
   ```

   1. `cd` into the repository directory:

   ```shell
   cd /var/opt/gitlab/git-data/repositories/@hashed/6f/4b/6f4b6612125fb3a0daecd2799dfd6c9c299424fd920f9b308110a2c1fbd8f443.git
   ```

   1. Unpack the objects:

   ```shell
   /opt/gitlab/embedded/bin/git unpack-objects < /tmp/missing-objects-<sha256sum>.pack
   ```

1. The missing objects should have been restored. You can check if via triggering another repository check or by running the
   following command:

   ```shell
   ## While still logged in as the Git user
   /opt/gitlab/embedded/bin/git fsck --full
   ```

   Output:

   ```shell
   Checking object directories: 100% (256/256), done.
   ```

#### From a backup of your GitLab instance

If you do not have anyone that has a working copy of the repository, the easiest way is to restore a backup of your GitLab instance
to a different server, export the affected project, and then restore it into your current GitLab instance. Please refer to the links
below for more information about this:

- [Backing up and restoring GitLab](../raketasks/backup_restore.md)
- [Project import/export](../user/project/settings/import_export.md)

---
[ce-3232]: https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/3232 "Auto git fsck"
[git-fsck]: https://git-scm.com/docs/git-fsck "git fsck documentation"
