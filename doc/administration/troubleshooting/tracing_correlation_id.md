---
type: reference
---

# Finding relevant log entries with a correlation ID

Since GitLab 11.6, a unique tracking ID, known as the "correlation ID" has been
logged for all requests in GitLab. This is great for tracking the logged
behavior in a precise manner. Without this approach and can be difficult or
impossible to match up log entries together.

## Getting the correlation ID

The correlation ID is logged in structured logs under the key `correlation_id`,
and is also logged in all response headers GitLab sends under the header
`x-request-id`. You can find your correlation ID by searching in either place.

### Getting the correlation ID in your browser

You can use your browser's developer tools to monitor and inspect network
activity on site that you're visiting. See below links for network monitor
documenation for a few different popular browsers.

- [Network Monitor - Firefox Developer Tools](https://developer.mozilla.org/en-US/docs/Tools/Network_Monitor)
- [Inspect Network Activity In Chrome DevTools](https://developers.google.com/web/tools/chrome-devtools/network/)
- [Safari Web Development Tools](https://developer.apple.com/safari/tools/)
- [Microsoft Edge Network panel](https://docs.microsoft.com/en-us/microsoft-edge/devtools-guide/network#request-details)

Some actions in GitLab will redirect you quickly after you submit a form, so
you will want to enable persistent logging in your network monitor. Then you'll
want to click on the request in question for more details (it might help to
filter to "document" requests), go to the "headers" section and look for the
_response_ headers. There you should find an `x-request-id` header with a
randomly generated value. Below is an example:

![Firefox's network monitor showing an request id header](img/network_monitor_xid.png)

### Getting the correlation ID from your logs

Another approach to finding the correct correlation ID is to search or watch
your logs and find the `correlation_id` value for the log entry that you're
watching for.

For example, let's say that you want learn what's happening or breaking when
you reproduce an action in GitLab. You could tail the GitLab logs, filtering
to requests by your user, and then watch the requests until you see what you're
interested in.

#### Using jq

This example uses [jq](https://stedolan.github.io/jq/) to filter results and
display values we most likely care about.

```sh
sudo gitlab-ctl tail gitlab-rails/production_json.log | jq 'select(.username == "bob") | "User: \(.username), \(.method) \(.path), \(.controller)#\(.action), ID: \(.correlation_id)"'
```

```text
"User: bob, GET /root/linux, ProjectsController#show, ID: U7k7fh6NpW3"
"User: bob, GET /root/linux/commits/master/signatures, Projects::CommitsController#signatures, ID: XPIHpctzEg1"
"User: bob, GET /root/linux/blob/master/README, Projects::BlobController#show, ID: LOt9hgi1TV4"
```

#### Using grep

This example uses only grep and tr, which are more likely to be installed than jq.

```sh
sudo gitlab-ctl tail gitlab-rails/production_json.log | grep '"username":"bob"' | tr ',' '\n' | egrep 'method|path|correlation_id'
```

```text
{"method":"GET"
"path":"/root/linux"
"username":"bob"
"correlation_id":"U7k7fh6NpW3"}
{"method":"GET"
"path":"/root/linux/commits/master/signatures"
"username":"bob"
"correlation_id":"XPIHpctzEg1"}
{"method":"GET"
"path":"/root/linux/blob/master/README"
"username":"bob"
"correlation_id":"LOt9hgi1TV4"}
```

## Searching your logs for the correlation ID

Once you have the correlation ID you can start searching for relevant log
entries. You can simply filter the lines by the correlation ID itself since it
is unique enough that there shouldn't be any duplicates. A simple find & grep
combo should find what you're looking for.

```sh
# find <gitlab log directory> -type f -mtime -0 exec grep '<correlation ID>' '{}' '+'
find /var/log/gitlab -type f -mtime 0 -exec grep 'LOt9hgi1TV4' '{}' '+'
```

```text
/var/log/gitlab/gitlab-workhorse/current:{"correlation_id":"LOt9hgi1TV4","duration_ms":2478,"host":"gitlab.domain.tld","level":"info","method":"GET","msg":"access","proto":"HTTP/1.1","referrer":"https://gitlab.domain.tld/root/linux","remote_addr":"68.0.116.160:0","remote_ip":"[filtered]","status":200,"system":"http","time":"2019-09-17T22:17:19Z","uri":"/root/linux/blob/master/README?format=json\u0026viewer=rich","user_agent":"Mozilla/5.0 (Mac) Gecko Firefox/69.0","written_bytes":1743}
/var/log/gitlab/gitaly/current:{"correlation_id":"LOt9hgi1TV4","grpc.code":"OK","grpc.meta.auth_version":"v2","grpc.meta.client_name":"gitlab-web","grpc.method":"FindCommits","grpc.request.deadline":"2019-09-17T22:17:47Z","grpc.request.fullMethod":"/gitaly.CommitService/FindCommits","grpc.request.glProjectPath":"root/linux","grpc.request.glRepository":"project-1","grpc.request.repoPath":"@hashed/6b/86/6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b.git","grpc.request.repoStorage":"default","grpc.request.topLevelGroup":"@hashed","grpc.service":"gitaly.CommitService","grpc.start_time":"2019-09-17T22:17:17Z","grpc.time_ms":2319.161,"level":"info","msg":"finished streaming call with code OK","peer.address":"@","span.kind":"server","system":"grpc","time":"2019-09-17T22:17:19Z"}
/var/log/gitlab/gitlab-rails/production_json.log:{"method":"GET","path":"/root/linux/blob/master/README","format":"json","controller":"Projects::BlobController","action":"show","status":200,"duration":2448.77,"view":0.49,"db":21.63,"time":"2019-09-17T22:17:19.800Z","params":[{"key":"viewer","value":"rich"},{"key":"namespace_id","value":"root"},{"key":"project_id","value":"linux"},{"key":"id","value":"master/README"}],"remote_ip":"[filtered]","user_id":2,"username":"bob","ua":"Mozilla/5.0 (Mac) Gecko Firefox/69.0","queue_duration":3.38,"gitaly_calls":1,"gitaly_duration":0.77,"rugged_calls":4,"rugged_duration_ms":28.74,"correlation_id":"LOt9hgi1TV4"}
```

### Searching in distributed architectures

If you have done some horizontal scaling in your GitLab infrastructure, then
you will need to search across _all_ of your GitLab nodes. You can do this with
some sort of log aggregation software like Loki, ELK, Splunk, or others.
Something like Ansible or pssh (parellel ssh), that can execute commands across your servers in
parallel, could be used to execute the same search command. Or you could craft your own solution.
