---
type: reference
---

# Version Check **(CORE ONLY)**

If enabled, version check will inform you if a new version is available and the
importance of it through a status. This is shown on the help page (i.e. `/help`)
for all signed in users, and on the admin pages. The statuses are:

- Green: You are running the latest version of GitLab.
- Orange: An updated version of GitLab is available.
- Red: The version of GitLab you are running is vulnerable. You should install
  the latest version with security fixes as soon as possible.

![Orange version check example](img/update-available.png)

GitLab Inc. collects your instance's version and hostname (through the HTTP
referer) as part of the version check. No other information is collected.

This information is used, among other things, to identify to which versions
patches will need to be backported, making sure active GitLab instances remain
secure.

If you disable version check, this information will not be collected. Enable or
disable the version check in **Admin Area > Settings > Metrics and profiling > Usage statistics**.

## Request flow example

The following example shows a basic request/response flow between the self-managed GitLab instance
and the GitLab Version Application:

```mermaid
sequenceDiagram
    participant GitLab instance
    participant Version Application
    GitLab instance->>Version Application: Is there a version update?
    loop Version Check
        Version Application->>Version Application: Record version info
    end
    Version Application->>GitLab instance: Response (PNG/SVG)
```

## Usage statistics **(CORE ONLY)**

GitLab Inc. will periodically collect information about your instance in order
to perform various actions.

All statistics are opt-out. You can enable/disable them in the
**Admin Area > Settings > Metrics and profiling** section **Usage statistics**.

## Network configuration

Allow network traffic from your GitLab instance to IP address `104.196.17.203:443`, to send
usage statistics to GitLab Inc.

If your GitLab instance is behind a proxy, set the appropriate [proxy configuration variables](https://docs.gitlab.com/omnibus/settings/environment-variables.html).
