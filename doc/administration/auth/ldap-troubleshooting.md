# LDAP Troubleshooting for Administrators

## Troubleshooting Workflow

As an admin troubleshooting LDAP, familiarize yourself with the [various
debugging tools](#debugging-tools) you can use and how you can use them.

**Users can't login**

Run the [LDAP rake task](#ldap-check) to confirm whether a connection to LDAP can
be established and LDAP users can be found.

  - Does it successfully connect to the LDAP server?
  If it doesn't, go to [Connection failures](#connection-failures).
  - If it successfully connects, the output [should also return up to
  100 users][ldap-check]. Do you see them in the output? If
  not, go to [LDAP users not found](#ldap-users-not-found).
  - Does it connect successfully, return users, but one or more users
  are denied access? If so, go to [Users cannot login](#users-cannot-login).

**Users can login but they aren't getting access to a group**

Go to [Group Sync failures](#group-sync-failures).

**Users can login but they aren't given Admin or External user access**

Go to [Admin/External access failures](#adminexternal-access-failures).

## Debugging tools

### GitLab Logs

If a user account is blocked or unblocked due to the LDAP configuration, a
message will be [logged to `application.log`][application-log].

If there is an unexpected error during an LDAP lookup (configuration error,
timeout), the login is rejected and a message will be [logged to
`production.log`][production-log].

### ldapsearch

`ldapsearch` is a utility that will allow you to query your LDAP server. You can
use it to test your LDAP settings and ensure that the settings you're using
will get you the results you expect.

When using `ldapsearch`, be sure to use the same settings you've already
specified in your `gitlab.rb` configuration so you can confirm what happens
when those exact settings are used.

Running this command on the GitLab host will also help confirm that it's
possible for a network connection to be made to LDAP.

For example, consider the following GitLab configuration:

```bash
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
   main: # 'main' is the GitLab 'provider ID' of this LDAP server
     label: 'LDAP'
     host: '127.0.0.1'
     port: 389
     uid: 'uid'
     encryption: 'plain'
     bind_dn: 'cn=admin,dc=ldap-testing,dc=example,dc=com'
     password: 'Password1'
     active_directory: true
     allow_username_or_email_login: false
     block_auto_created_users: false
     base: 'dc=ldap-testing,dc=example,dc=com'
     user_filter: ''
     attributes:
       username: ['uid', 'userid', 'sAMAccountName']
       email:    ['mail', 'email', 'userPrincipalName']
       name:       'cn'
       first_name: 'givenName'
       last_name:  'sn'
     group_base: 'ou=groups,dc=ldap-testing,dc=example,dc=com'
     admin_group: 'gitlab_admin'
EOS
```

You would run the following `ldapsearch` to find the `bind_dn` user:

```bash
ldapsearch -D "cn=admin,dc=ldap-testing,dc=example,dc=com" \
  -w Password1 \
  -p 389 \
  -h 127.0.0.1 \
  -b "dc=ldap-testing,dc=example,dc=com"
```

Note that the `bind_dn`, `password`, `port`, `host`, and `base` are all
identical to what's configured in the `gitlab.rb`.

Please see [the official
`ldapsearch` documentation](https://linux.die.net/man/1/ldapsearch) for more.

#### Debug LDAP user filter with ldapsearch

This example assumes you are using ActiveDirectory. The
following query returns the login names of the users that will be allowed to
log in to GitLab if you configure your own user_filter.

```sh
ldapsearch -H ldaps://$host:$port -D "$bind_dn" -y bind_dn_password.txt  -b "$base" "$user_filter" sAMAccountName
```

- Variables beginning with a `$` refer to a variable from the LDAP section of
  your configuration file.
- Replace `ldaps://` with `ldap://` if you are using the plain authentication method.
  Port `389` is the default `ldap://` port and `636` is the default `ldaps://`
  port.
- We are assuming the password for the `bind_dn` user is in `bind_dn_password.txt`.

### LDAP check

The [rake task to check LDAP][ldap-check] is a valuable tool
to help determine whether GitLab can successfully establish a connection to
LDAP and can get so far as to even read users.

If a connection can't be established, it is likely either because of your
configuration or the connection itself. Re-visit your LDAP configuration and
use [`ldapsearch`](#ldapsearch) to debug where it could be failing.

If GitLab can successfully connect to LDAP but doesn't return any
users, it's likely that either users don't fall under your configured `base`
or they don't filter through any configured `user_filter`. Once again, you can
use [`ldapsearch`](#ldapsearch) to help find the culprit.

### Rails console

CAUTION: **CAUTION:**
Please note that it is very easy to create, read, modify, and destroy data on the
rails console, so please be sure to run commands exactly as listed.

The rails console is a valuable tool to help debug LDAP problems. It allows you to
directly interact with the application by running commands and seeing how GitLab
responds to them.

Please refer to [this guide](https://docs.gitlab.com/omnibus/maintenance/#starting-a-rails-console-session)
for instructions on how to use the rails console.

#### Get debug output

This will provide debug output that can be useful to see
what GitLab is doing and with what. This value is not persisted.

To enable debug output in the rails console, [enter the rails
console](#rails-console) and run:

```ruby
Rails.logger.level = Logger::DEBUG
```

#### Query a user in LDAP

This could expose potential errors connecting to and/or querying LDAP that may seem to
fail silently in the GitLab UI. This [requires debug output](#get-debug-output).

```ruby
Rails.logger.level = Logger::DEBUG
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
user = Gitlab::Auth::LDAP::Person.find_by_uid('<username>', adapter)
```

#### Sync all users **(STARTER ONLY)**

The output from a manual [user sync][user-sync] can show you what happens when
GitLab tries to sync its users against LDAP.

Once you've run the following in the [rails console](#rails-console), find a
user with their DN or email.

```ruby
Rails.logger.level = Logger::DEBUG
LdapSyncWorker.new.perform
```

Next, [learn how to read the output](#example-log-output-after-a-user-sync).

#### Sync all groups **(STARTER ONLY)**

NOTE: **NOTE:**
To sync all groups manually when debugging is unnecessary, [use the rake
task](../raketasks/ldap.md#run-a-group-sync) instead.

```ruby
LdapAllGroupsSyncWorker.new.perform
```

#### Sync one group **(STARTER ONLY)**

```ruby
group = Group.find_by(name: 'my_gitlab_group')
EE::Gitlab::Auth::LDAP::Sync::Group.execute_all_providers(group)
```

#### Query a group in LDAP **(STARTER ONLY)**

```ruby
# Find the adapter and the group itself
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
ldap_group = EE::Gitlab::Auth::LDAP::Group.find_by_cn('group_cn_here', adapter)

# Find the members of the LDAP group
ldap_group.member_dns
ldap_group.member_uids
```

#### Query LDAP **(STARTER ONLY)**

If you'd like to see whether GitLab has access to a certain user or group, you
can try the following.

```ruby
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain')
options = {
    # :base is required
    # use .base or .group_base
    base: adapter.config.group_base,

    # :filter is optional
    # 'cn' looks for all "cn"s under :base
    # '*' is the search string - here, it's a wildcard
    filter: Net::LDAP::Filter.eq('cn', '*'),

    # :attributes is optional
    # the attributes we want to get returned
    attributes: %w(dn cn memberuid member submember uniquemember memberof)
}
adapter.ldap_search(options)
```

For an example, [see the code](https://gitlab.com/gitlab-org/gitlab-ee/blob/master/ee/lib/ee/gitlab/auth/ldap/adapter.rb)

#### Example log output after a user sync **(STARTER ONLY)**

The output from a [user sync](#debug-a-usersync) will be verbose, and will
look like this:

```sql
Syncing user John, email@example.com
  Identity Load (0.9ms)  SELECT  "identities".* FROM "identities" WHERE "identities"."user_id" = 20 AND (provider LIKE 'ldap%') LIMIT 1
Instantiating Gitlab::Auth::LDAP::Person with LDIF:
dn: cn=John Smith,ou=people,dc=example,dc=com
cn: John Smith
mail: email@example.com
memberof: cn=admin_staff,ou=people,dc=example,dc=com
uid: John

  UserSyncedAttributesMetadata Load (0.9ms)  SELECT  "user_synced_attributes_metadata".* FROM "user_synced_attributes_metadata" WHERE "user_synced_attributes_metadata"."user_id" = 20 LIMIT 1
   (0.3ms)  BEGIN
  Namespace Load (1.0ms)  SELECT  "namespaces".* FROM "namespaces" WHERE "namespaces"."owner_id" = 20 AND "namespaces"."type" IS NULL LIMIT 1
  Route Load (0.8ms)  SELECT  "routes".* FROM "routes" WHERE "routes"."source_id" = 27 AND "routes"."source_type" = 'Namespace' LIMIT 1
  Ci::Runner Load (1.1ms)  SELECT "ci_runners".* FROM "ci_runners" INNER JOIN "ci_runner_namespaces" ON "ci_runners"."id" = "ci_runner_namespaces"."runner_id" WHERE "ci_runner_namespaces"."namespace_id" = 27
   (0.7ms)  COMMIT
   (0.4ms)  BEGIN
  Route Load (0.8ms)  SELECT "routes".* FROM "routes" WHERE (LOWER("routes"."path") = LOWER('John'))
  Namespace Load (1.0ms)  SELECT  "namespaces".* FROM "namespaces" WHERE "namespaces"."id" = 27 LIMIT 1
  Route Exists (0.9ms)  SELECT  1 AS one FROM "routes" WHERE LOWER("routes"."path") = LOWER('John') AND "routes"."id" != 50 LIMIT 1
  User Update (1.1ms)  UPDATE "users" SET "updated_at" = '2019-10-17 14:40:59.751685', "last_credential_check_at" = '2019-10-17 14:40:59.738714' WHERE "users"."id" = 20
```

Let's break it down. First, you'll see the user's name and email, as they
exist in GitLab now:

```ruby
Syncing user John, email@example.com
```

Next, GitLab searches the `identities` table in its database for the existing
link between this user and the configured LDAP provider(s):

```sql
  Identity Load (0.9ms)  SELECT  "identities".* FROM "identities" WHERE "identities"."user_id" = 20 AND (provider LIKE 'ldap%') LIMIT 1
```

The identity found will contain an `extern_uid` value, which will be the DN of
the user.

```ruby
Instantiating Gitlab::Auth::LDAP::Person with LDIF:
dn: cn=John Smith,ou=people,dc=example,dc=com
cn: John Smith
mail: email@example.com
memberof: cn=admin_staff,ou=people,dc=example,dc=com
uid: John
```

If the user wasn't found in LDAP with either the DN or email, you may see the
following error instead:

```ruby
LDAP search error: No Such Object
```

...in which case the user will be blocked:

```ruby
  User Update (0.4ms)  UPDATE "users" SET "state" = $1, "updated_at" = $2 WHERE "users"."id" = $3  [["state", "ldap_blocked"], ["updated_at", "2019-10-18 15:46:22.902177"], ["id", 51]]
```

If there's a failure or an error, it will be visible in the output.

#### Example log output after a group sync **(STARTER ONLY)**

The output [from running a group sync](#sync-all-groups) will be very verbose,
but contains lots of helpful information. For the most part you can ignore log
entries that are SQL statements.

**Find why members aren't assigned to a group**

Indicates the point where syncing actually begins:

```bash
Started syncing all providers for 'my_group' group
```

The follow entry shows an array of all user DNs GitLab sees in the LDAP server.
Note that these are the users for a single LDAP group, not a GitLab group. If
you have multiple LDAP groups linked to this GitLab group, you will see multiple
log entries like this - one for each LDAP group. If you don't see an LDAP user
DN in this log entry, LDAP is not returning the user when we do the lookup.
Verify the user is actually in the LDAP group.

```bash
Members in 'ldap_group_1' LDAP group: ["uid=john0,ou=people,dc=example,dc=com",
"uid=mary0,ou=people,dc=example,dc=com", "uid=john1,ou=people,dc=example,dc=com",
"uid=mary1,ou=people,dc=example,dc=com", "uid=john2,ou=people,dc=example,dc=com",
"uid=mary2,ou=people,dc=example,dc=com", "uid=john3,ou=people,dc=example,dc=com",
"uid=mary3,ou=people,dc=example,dc=com", "uid=john4,ou=people,dc=example,dc=com",
"uid=mary4,ou=people,dc=example,dc=com"]
```

Shortly after each of the above entries, you will see a hash of resolved member
access levels. This hash represents all user DNs GitLab thinks should have
access to this group, and at which access level (role). This hash is additive,
and more DNs may be added, or existing entries modified, based on additional
LDAP group lookups. The very last occurrence of this entry should indicate
exactly which users GitLab believes should be added to the group.

NOTE: **Note:**
10 is 'Guest', 20 is 'Reporter', 30 is 'Developer', 40 is 'Maintainer'
and 50 is 'Owner'.

```bash
Resolved 'my_group' group member access: {"uid=john0,ou=people,dc=example,dc=com"=>30,
"uid=mary0,ou=people,dc=example,dc=com"=>30, "uid=john1,ou=people,dc=example,dc=com"=>30,
"uid=mary1,ou=people,dc=example,dc=com"=>30, "uid=john2,ou=people,dc=example,dc=com"=>30,
"uid=mary2,ou=people,dc=example,dc=com"=>30, "uid=john3,ou=people,dc=example,dc=com"=>30,
"uid=mary3,ou=people,dc=example,dc=com"=>30, "uid=john4,ou=people,dc=example,dc=com"=>30,
"uid=mary4,ou=people,dc=example,dc=com"=>30}
```

It's not uncommon to see warnings like the following. These indicate that GitLab
would have added the user to a group, but the user could not be found in GitLab.
Usually this is not a cause for concern.

If you think a particular user should already exist in GitLab, but you're seeing
this entry, it could be due to a mismatched DN stored in GitLab. See
[User DN and/or email have changed](#user-dn-orand-email-have-changed) to update the user's LDAP identity.

```bash
User with DN `uid=john0,ou=people,dc=example,dc=com` should have access
to 'my_group' group but there is no user in GitLab with that
identity. Membership will be updated once the user signs in for
the first time.
```

Finally, the following entry says syncing has finished for this group:

```bash
Finished syncing all providers for 'my_group' group
```

**Debugging why admins aren't granted access**

## Common Problems and Errors

### Connection to LDAP

#### Connection refused

If you are getting 'Connection Refused' errors when trying to connect to the
LDAP server please double-check the LDAP `port` and `encryption` settings used by
GitLab. Common combinations are `encryption: 'plain'` and `port: 389`, OR
`encryption: 'simple_tls'` and `port: 636`.

#### Connection times out

If GitLab cannot reach your LDAP endpoint, you will see a message like this:

```
Could not authenticate you from Ldapmain because "Connection timed out - user specified timeout".
```

If your configured LDAP provider and/or endpoint is offline or otherwise unreachable by GitLab, no LDAP user will be able to authenticate and log in. GitLab does not cache or store credentials for LDAP users to provide authentication during an LDAP outage.

Contact your LDAP provider or administrator if you are seeing this error.

#### Referral error

If you see `LDAP search error: Referral` in the logs, or when troubleshooting
LDAP Group Sync, this error may indicate a configuration problem. The LDAP
configuration `/etc/gitlab/gitlab.rb` (Omnibus) or `config/gitlab.yml` (source)
is in YAML format and is sensitive to indentation. Check that `group_base` and
`admin_group` configuration keys are indented 2 spaces past the server
identifier. The default identifier is `main` and an example snippet looks like
the following:

```yaml
main: # 'main' is the GitLab 'provider ID' of this LDAP server
  label: 'LDAP'
  host: 'ldap.example.com'
  ...
  group_base: 'cn=my_group,ou=groups,dc=example,dc=com'
  admin_group: 'my_admin_group'
```

#### All users are getting blocked

### User Logins

This section implies that a [connection to the LDAP server can be
established](#narrowing-down-the-problem), but one or more users can't login.

#### No users are found

If [you've confirmed](#ldap-check) that a connection to LDAP can be
established but GitLab doesn't show you LDAP users in the output, one of the
following is most likely true:

  - The `bind_dn` user doesn't have enough permissions to traverse the user tree
  - The user(s) don't fall under the [configured `base`](ldap.md#configuration)
  - The configured `user_filter` blocks access to the user(s)

In this case, you con confirm which of the above is true using
[ldapsearch](#ldapsearch) with the existing LDAP configuration in your
`/etc/gitlab/gitlab.rb`.

#### User(s) cannot login

As the user tries to login, [tail the logs][tail-logs] and [look through the
output](#using-logs) for any errors or other messages pertaining to this user.

It can also be helpful to [try finding the user]() or
[debug a user sync](#debug-a-user-sync) **(STARTER ONLY)** to investigate
further.

Also see [Invalid credentials when logging in](#invalid-credentials-when-logging-in).

#### Invalid credentials when logging in

- Make sure the user you are binding with has enough permissions to read the user's
  tree and traverse it.
- Check that the `user_filter` is not blocking otherwise valid users.
- Run [an LDAP check command](#ldap-check) to make sure that the LDAP settings
  are correct and [GitLab can see your users](#ldap-users-not-found).

#### Email has already been taken

A user tries to login with the correct LDAP credentials, is denied access,
and the [production.log][production-log] shows an error that looks like this:

```sh
(LDAP) Error saving user <USER DN> (email@example.com): ["Email has already been taken"]
```

This error is referring to the email address in LDAP, `email@example.com`. Email
addresses must be unique in GitLab and LDAP uses a user's primary email (as opposed
to any of their possibly-numerous secondary emails). Another user (or even the
same user) has the email `email@example.com` set as a secondary email, which
is throwing this error.

We can check where this conflicting email address is coming from using the
[rails console](#rails-console). Once in the console, run the following:

```ruby
# This searches for an email among the primary AND secondary emails
user = User.find_by_any_email('email@example.com')
user.username
```

This will show you which user has this email address. One of two steps will
have to be taken here:

  - To create a new GitLab user/username for this user when logging in with LDAP,
    remove the secondary email to remove the conflict.
  - To use an existing GitLab user/username for this user to use with LDAP,
    remove this email as a secondary email and make it a primary one so GitLab
    will associate this profile to the LDAP identity.

The user can do either of these steps [in their
profile](../../user/profile/index.md#user-profile) or an admin can do it.

### User Permissions or Access to Groups **(STARTER ONLY)**

#### User is not being added to a group **(STARTER ONLY)**

Sometimes you may think a particular user should be added to a GitLab group via
LDAP group sync, but for some reason it's not happening. There are several
things to check to debug the situation.

- Ensure LDAP configuration has a `group_base` specified. This configuration is
  required for group sync to work properly.
- Ensure the correct LDAP group link is added to the GitLab group. Check group
  links by visiting the GitLab group, then **Settings dropdown > LDAP groups**.
- Check that the user has an LDAP identity:
  1. Sign in to GitLab as an administrator user.
  1. Navigate to **Admin area > Users**.
  1. Search for the user
  1. Open the user, by clicking on their name. Do not click 'Edit'.
  1. Navigate to the **Identities** tab. There should be an LDAP identity with
     an LDAP DN as the 'Identifier'.

If all of the above looks good, jump in to a little more advanced debugging.
Often, the best way to learn more about why group sync is behaving a certain
way is to enable debug logging. There is verbose output that details every
step of the sync.

1. Start a Rails console:

   ```bash
   # For Omnibus installations
   sudo gitlab-rails console

   # For installations from source
   sudo -u git -H bundle exec rails console production
   ```

1. Set the log level to debug (only for this session):

   ```ruby
   Rails.logger.level = Logger::DEBUG
   ```

1. Choose a GitLab group to test with. This group should have an LDAP group link
   already configured. If the output is `nil`, the group could not be found.
   If a bunch of group attributes are output, your group was found successfully.

   ```ruby
   group = Group.find_by(name: 'my_group')

   # Output
   => #<Group:0x007fe825196558 id: 1234, name: "my_group"...>
   ```

1. Run a group sync for this particular group.

   ```ruby
   EE::Gitlab::Auth::LDAP::Sync::Group.execute_all_providers(group)
   ```

1. Look through the output of the sync. See [example log output](#example-log-output)
   below for more information about the output.
1. If you still aren't able to see why the user isn't being added, query the
   LDAP group directly to see what members are listed. Still in the Rails console,
   run the following query:

   ```ruby
   adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
   ldap_group = EE::Gitlab::Auth::LDAP::Group.find_by_cn('group_cn_here', adapter)

   # Output
   => #<EE::Gitlab::Auth::LDAP::Group:0x007fcbdd0bb6d8
   ```

1. Query the LDAP group's member DN and see if the user's DN is in the list.
   One of the DN here should match the 'Identifier' from the LDAP identity
   checked earlier. If it doesn't, the user does not appear to be in the LDAP
   group.

   ```ruby
   ldap_group.member_dns

   # Output
   => ["uid=john,ou=people,dc=example,dc=com", "uid=mary,ou=people,dc=example,dc=com"]
   ```

1. Some LDAP servers don't store members by DN. Rather, they use UIDs instead.
   If you didn't see results from the last query, try querying by UIDs instead.

   ```ruby
   ldap_group.member_uids

   # Output
   => ['john','mary']
   ```

#### Admin priviliges not granted

When [Administrator sync](ldap-ee.md#administrator-sync) has been configured
but the configured users aren't granted the correct admin privileges, confirm
the following are true:

- A [`group_base` is also configured](ldap-ee.md#group-sync)
- The configured `admin_group` in the `gitlab.rb` is a CN, rather than a DN or an array
- This CN falls under the configured `group_base`
- The users to be admins have already logged into GitLab with their LDAP
  credentials. Only users that have logged in to GitLab with their LDAP
  credentials will be granted this access.

If all the above are true and the users are still not getting access, [sync
all groups in the rails console](#sync-all-groups), [look for the relevant
section in the logs](), and the output will have more details to understand
why.

### User DN or/and email have changed

When an LDAP user is created in GitLab, their LDAP DN is stored for later reference.

If GitLab cannot find a user by their DN, it will attempt to fallback
to finding the user by their email. If the lookup is successful, GitLab will
update the stored DN to the new value.

If the email has changed and the DN has not, GitLab will find the user with
the DN and update its own record of the user's email to match the one in LDAP.

However, if the primary email _and_ the DN change in LDAP, then GitLab will
have no way of identifying the correct LDAP record of the user and, as a
result, the user will be blocked. To rectify this, the user's existing
profile will have to be updated with at least one of the new values (primary
email or DN) so the LDAP record can be found.

The following script will update the emails for all provided users so they
won't be blocked or unable to access their accounts.

>**NOTE**: The following script will require that any new accounts with the new
email address are removed. This is because emails have to be unique in GitLab.

Go to the [rails console](#rails-console) and then run:

```ruby
# Each entry will have to include the old username and the new email
emails = {
  'ORIGINAL_USERNAME' => 'NEW_EMAIL_ADDRESS',
  ...
}

emails.each do |username, email|
  user = User.find_by_username(username)
  user.email = email
  user.skip_reconfirmation!
  user.save!
end
```

You can then [run a UserSync](#usersync) **(STARTER ONLY)** to sync the latest DN
for each of these users.

<!-- LINK REFERENCES -->

[tail-logs]: https://docs.gitlab.com/omnibus/settings/logs.html#tail-logs-in-a-console-on-the-server
[production-log]: ../logs.md#productionlog
[application-log]: ../logs.md#applicationlog
[reconfigure]: ../restart_gitlab.md#omnibus-gitlab-reconfigure
[restart]: ../restart_gitlab.md#installations-from-source
[ldap-check]: ../raketasks/ldap.md#check
[user-sync]: ldap-ee.md#user-sync
[config]: ldap.md#configuration

[^1]: In Active Directory, a user is marked as disabled/blocked if the user
      account control attribute (`userAccountControl:1.2.840.113556.1.4.803`)
      has bit 2 set. See <https://ctogonewild.com/2009/09/03/bitmask-searches-in-ldap/>
      for more information.
