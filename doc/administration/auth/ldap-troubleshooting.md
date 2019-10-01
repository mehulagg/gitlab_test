# LDAP Troubleshooting for Administrators

## Debugging tools

### ldapsearch

`ldapsearch` is a utility that will allow you to query your LDAP server. You can
use it to test your LDAP settings and ensure that the settings you're using
will get you the results you expect.

When using `ldapsearch`, be sure to use the same settings you've already
specified in your `gitlab.rb` configuration so you can confirm what happens
when those exact settings are used.

Please see [the official
`ldapsearch` documentation](https://linux.die.net/man/1/ldapsearch) for
the available flags.

We also recommended running this command directly on the GitLab host.

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

### Check LDAP connection

Once LDAP has been configured and you'd like to test that GitLab is
successfully able to connect to the LDAP server and read users, run the [LDAP
rake task to do so](../raketasks/ldap.md#check).

If GitLab can successfully connect to LDAP but doesn't return any
users, it's likely that either users don't fall under your configured `base`
or they don't filter through any configured `user_filter`.

## Common workflows
### Connection errors
### Errors on User logins
### Errors with Group memberships
## Misc.










## Rails console debugging

Here are some rails console commands you can run to help debug problems you're
running into with LDAP. Please note that these commands are all READ-ONLY so
they won't make any permanent changes.

Enter the rails console with `gitlab-rails console`.

### Get debug output

This will provide a greater level of debug output that can be useful to see
what GitLab is doing and with what. This value is not persisted, and is
required to see output for many of the rails console commands on this page.

```ruby
Rails.logger.level = Logger::DEBUG
```

### UserSync

Run a [user sync]() and watch the output for what GitLab finds in LDAP and
what it does with it. This requires the [debug output](#get-debug-output) be
enabled.

This can be helpful when debugging why a particular user isn't getting found.

```ruby
LdapSyncWorker.new.perform
```

### GroupSync

#### Sync all groups

NOTE: **NOTE:**
To simply sync all groups manually, [use the rake
command](../raketasks/ldap.md#run-a-group-sync).

```ruby
LdapAllGroupsSyncWorker.new.perform
```

#### Sync one group

```ruby
group = Group.find_by(name: 'my_gitlab_group')
EE::Gitlab::Auth::LDAP::Sync::Group.execute_all_providers(group)
```

#### Query an LDAP group directly

```ruby
# Find the adapter and the group itself
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
ldap_group = EE::Gitlab::Auth::LDAP::Group.find_by_cn('group_cn_here', adapter)

# Find the members of the LDAP group
ldap_group.member_dns
ldap_group.member_uids
```

### AdminSync

#### Admin priviliges not granted

- DETAIL HOW TO DEBUG THIS

### Users

#### Find a user

```ruby
# This could expose potential errors connecting to and/or querying LDAP that may seem to
# fail silently in the GitLab UI
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
user = Gitlab::Auth::LDAP::Person.find_by_uid('<username>',adapter)
```

#### Query LDAP

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

### Update user accounts when the `dn` and email change

The following will require that any accounts with the new email address are removed.  Emails have to be unique in GitLab.  This is expected to work but unverified as of yet.

```ruby
# Here's an example with a couple users.
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

# Run a UserSync to sync the above users' data
LdapSyncWorker.new.perform
```

### Referral error

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

[reconfigure]: ../restart_gitlab.md#omnibus-gitlab-reconfigure
[restart]: ../restart_gitlab.md#installations-from-source

[^1]: In Active Directory, a user is marked as disabled/blocked if the user
      account control attribute (`userAccountControl:1.2.840.113556.1.4.803`)
      has bit 2 set. See <https://ctogonewild.com/2009/09/03/bitmask-searches-in-ldap/>
      for more information.

### User DN has changed

When an LDAP user is created in GitLab, their LDAP DN is stored for later reference.

If GitLab cannot find a user by their DN, it will attempt to fallback
to finding the user by their email. If the lookup is successful, GitLab will
update the stored DN to the new value.

### User is not being added to a group

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

1. Query the LDAP group's member DNs and see if the user's DN is in the list.
   One of the DNs here should match the 'Identifier' from the LDAP identity
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

#### Example log output

The output of the last command will be very verbose, but contains lots of
helpful information. For the most part you can ignore log entries that are SQL
statements.

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
[User DN has changed](#User-DN-has-changed) to update the user's LDAP identity.

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

### Using logs

If a user account is blocked or unblocked due to the LDAP configuration, a
message will be logged to `application.log`.

If there is an unexpected error during an LDAP lookup (configuration error,
timeout), the login is rejected and a message will be logged to
`production.log`.

### Debug LDAP user filter with ldapsearch

This example uses `ldapsearch` and assumes you are using ActiveDirectory. The
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
- We are assuming the password for the bind_dn user is in bind_dn_password.txt.

### Invalid credentials when logging in

- Make sure the user you are binding with has enough permissions to read the user's
  tree and traverse it.
- Check that the `user_filter` is not blocking otherwise valid users.
- Run the following check command to make sure that the LDAP settings are
  correct and GitLab can see your users:

  ```bash
  # For Omnibus installations
  sudo gitlab-rake gitlab:ldap:check

  # For installations from source
  sudo -u git -H bundle exec rake gitlab:ldap:check RAILS_ENV=production
  ```

### Connection refused

If you are getting 'Connection Refused' errors when trying to connect to the
LDAP server please double-check the LDAP `port` and `encryption` settings used by
GitLab. Common combinations are `encryption: 'plain'` and `port: 389`, OR
`encryption: 'simple_tls'` and `port: 636`.

### Connection times out

If GitLab cannot reach your LDAP endpoint, you will see a message like this:

```
Could not authenticate you from Ldapmain because "Connection timed out - user specified timeout".
```

If your configured LDAP provider and/or endpoint is offline or otherwise unreachable by GitLab, no LDAP user will be able to authenticate and log in. GitLab does not cache or store credentials for LDAP users to provide authentication during an LDAP outage.

Contact your LDAP provider or administrator if you are seeing this error.
