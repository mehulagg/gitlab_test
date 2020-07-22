# The Rails Console

The [Rails console](https://guides.rubyonrails.org/command_line.html#rails-console).
provides a way to interact with your GitLab instance from the command line.

CAUTION: **Caution:**
The Rails console interacts directly with GitLab. In many cases,
there are no handrails to prevent you from permanently modifying, corrupting
or destroying production data. If you would like to explore the Rails console
with no consequences, you are strongly advised to do so in a test environment.

The Rails console is for GitLab system administrators who are troubleshooting
a problem or need to retrieve some data that can only be done through direct
access of the GitLab application.

## Starting a Rails console session

**For Omnibus installations**

```shell
sudo gitlab-rails console
```

**For installations from source**

```shell
sudo -u git -H bundle exec rails console -e production
```

**For Kubernetes deployments**

The console is in the task-runner pod. Refer to our [Kubernetes cheat sheet](../troubleshooting/kubernetes_cheat_sheet.md#gitlab-specific-kubernetes-information) for details.

To exit the console, type: `quit`.

## Output Rails console session history

Enter the following command on the rails console to display
your command history.

```ruby
puts Readline::HISTORY.to_a
```

You can then copy it to your clipboard and save for future reference.

## Using the Rails Runner

If you need to run some Ruby code in the context of your GitLab production
environment, you can do so using the [Rails Runner](https://guides.rubyonrails.org/command_line.html#rails-runner).
When executing a script file, the script must be accessible by the `git` user.

When the command or script completes, the Rails runner process finishes.
It is useful for running within other scripts or cron jobs for example.

**For Omnibus installations**

```shell
sudo gitlab-rails runner "RAILS_COMMAND"

# Example with a two-line Ruby script
sudo gitlab-rails runner "user = User.first; puts user.username"

# Example with a ruby script file (make sure to use the full path)
sudo gitlab-rails runner /path/to/script.rb
```

**For installations from source**

```shell
sudo -u git -H bundle exec rails runner -e production "RAILS_COMMAND"

# Example with a two-line Ruby script
sudo -u git -H bundle exec rails runner -e production "user = User.first; puts user.username"

# Example with a ruby script file (make sure to use the full path)
sudo -u git -H bundle exec rails runner -e production /path/to/script.rb
```

Rails runner does not produce the same output as the console.

If you set a variable on the console, the console will generate useful debug output
such as the variable contents or properties of referenced entity:

```ruby
irb(main):001:0> user = User.first
=> #<User id:1 @root>
```

Rails runner does not do this: you have to be explicit about generating
output:

```shell
$ sudo gitlab-rails runner "user = User.first"
$ sudo gitlab-rails runner "user = User.first; puts user.username ; puts user.id"
root
1
```

Some basic knowledge of Ruby will be very useful. Try [this
30-minute tutorial](https://try.ruby-lang.org/) for a quick introduction.
Rails experience is helpful but not essential.
