---
type: reference
---

# Code intelligence (alpha)

We started developing [code intelligence](https://gitlab.com/groups/gitlab-org/-/epics/1576)
which makes possible to view the documentation of a particular method or jump to the definition of the method
while viewing or reviewing code.

The functionality is backed by [LSIF](https://lsif.dev/).
It is currently in the alpha stage and behind `code_navigation` feature flag,
but it is already possible to store the code intelligence data as a CI job artifact
and use it to provide documentation and a link to the definition of a method.

In order to store the code intelligence data, a new stage to `.gitlab-ci.yml` should be added.
The [example of one](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/362/diffs) for [gitlab-shell](https://gitlab.com/gitlab-org/gitlab-shell/-/blob/id-testing-code-navigation/cmd/check/main.go)
uses docker script which consists of the following commands:

```
FROM golang:1.13.0
RUN apt-get update && apt-get install -y ruby-full
RUN go get github.com/sourcegraph/lsif-go/cmd/lsif-go
CMD lsif-go && curl https://gitlab.com/igor.drozdov/lsif-transformer/-/raw/master/run.rb -o run.rb && ruby run.rb dump.lsif && mv dump.lsif.json lsif.json
```

[lsif-go](github.com/sourcegraph/lsif-go/cmd/lsif-go) generates LSIF file for the project and the [Ruby script](https://gitlab.com/igor.drozdov/lsif-transformer/-/raw/master/run.rb)
transforms it to a JSON file with the viable information.

After the job succeeds, it is possible to view the info about methods while browsing the code:

![Code intelligence](img/code_intelligence.png)
