---
stage: Verify
group: Continuous Integration
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Validate the `.gitlab-ci.yml` (API)

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/5953) in GitLab 8.12.

Checks if your `.gitlab-ci.yml` file is valid.

```plaintext
POST /ci/lint
```

| Attribute  | Type    | Required | Description |
| ---------- | ------- | -------- | -------- |
| `content`              | string     | yes      | the `.gitlab-ci.yaml` content|
| `include_merged_yaml`  | boolean    | no       | Whether to include the
expanded CI config in the response or not. |

```shell
curl --header "Content-Type: application/json" "https://gitlab.example.com/api/v4/ci/lint" --data '{"content": "{ \"image\": \"ruby:2.6\", \"services\": [\"postgres\"], \"before_script\": [\"bundle install\", \"bundle exec rake db:create\"], \"variables\": {\"DB_NAME\": \"postgres\"}, \"types\": [\"test\", \"deploy\", \"notify\"], \"rspec\": { \"script\": \"rake spec\", \"tags\": [\"ruby\", \"postgres\"], \"only\": [\"branches\"]}}"}'
```

Be sure to copy paste the exact contents of `.gitlab-ci.yml` as YAML is very picky about indentation and spaces.

Example responses:

- Valid content:

  ```json
  {
    "status": "valid",
    "errors": []
  }
  ```

- Invalid content:

  ```json
  {
    "status": "invalid",
    "errors": [
      "variables config should be a hash of key value pairs"
    ]
  }
  ```

- Without the content attribute:

  ```json
  {
    "error": "content is missing"
  }
  ```

## YAML expansion example

`.gitlab-ci.yml`

```yaml
include:
  remote: 'https://example.com/remote.yaml'

test:
  stage: test
  script:
    - echo 1
```

`https://example.com/remote.yaml`

```yaml
another_test:
  stage: test
  script:
    - echo 2
```

Example response:

  ```json
  {
    "status": "valid"
    "errors": [],
    "merged_config": "---\n:another_test:\n  :stage: test\n  :script: echo 2\n:test:\n  :stage: test\n  :script: echo 1\n"
  }
  ```
