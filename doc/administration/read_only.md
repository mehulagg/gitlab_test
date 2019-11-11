# GitLab read-only

In some cases you might want to place GitLab under a read-only state.
The configuration for doing so depends on your desired outcome.

## Repository read-only

The first thing you'll want to accomplish is to ensure that no changes can be made to your repositories.
Open up rails console with `gitlab-rails console` and execute the following command:

```rb
Project.all.each { |project| project.update!(repository_read_only: true) }
```

When you're ready to revert this, you can do so with the following command:

```rb
Project.all.each { |project| project.update!(repository_read_only: false) }
```



## Non-repository read-only

The next step is determined by what your desired outcome is.
If you don't mind shutting down the GitLab UI, then the easiest approach is to stop sidekiq and unicorn.
However, if you want to continue with the GitLab UI, then we'll need to take a few more steps regarding the database configuration

### Shutting down GitLab UI

By shutting down the GitLab UI, you'll effectively ensure that no changes can be made to GitLab.
The only thing you'll need to do is shutting down sidekiq and unicorn:

```sh
gitlab-ctl stop sidekiq
gitlab-ctl stop unicorn
```

When you're ready to revert this, you can do so with

```sh
gitlab-ctl start sidekiq
gitlab-ctl start unicorn
```

### Database read-only

If you want to allow users to use the GitLab UI, then you'll need to follow these steps to ensure that the database is read-only.

1. Enter PostgreSQL on the console as an admin user
```sh
 sudo \
    -u gitlab-psql /opt/gitlab/embedded/bin/psql \
    -h /var/opt/gitlab/postgresql gitlabhq_production
```
2.  create the read-only user. Note that the password is set to `mypassword`
```sql
-- NOTE: Use the password defined earlier
CREATE USER gitlab_read_only WITH password 'mypassword';
GRANT CONNECT ON DATABASE gitlabhq_production to gitlab_read_only;
GRANT USAGE ON SCHEMA public TO gitlab_read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gitlab_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO gitlab_read_only;

-- Tables created by "gitlab" should be made read-only for "gitlab_read_only"
-- automatically.
ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON TABLES TO gitlab_read_only;
ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON SEQUENCES TO gitlab_read_only;
```
3. Change the user in `/etc/gitlab/gitlab.rb`
```rb
postgresql['sql_user'] = "gitlab_read_only"
##! `SQL_USER_PASSWORD_HASH` can be generated using the command `gitlab-ctl pg-password-md5 gitlab_read_only` 
postgresql['sql_user_password'] = 'a2e20f823772650f039284619ab6f239' 
```

4. Run `gitlab-ctl reconfigure` and then `gitlab-ctl restart postgresql`

When you're ready to revert the read-only state, you'll need to comment out the lines from step 3
