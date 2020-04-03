# Hardening self-managed GitLab instances


## Visibility and Access

- Set default [project](https://docs.gitlab.com/ee/user/admin_area/settings/visibility_and_access_controls.html#default-project-visibility), [group](https://docs.gitlab.com/ee/user/admin_area/settings/visibility_and_access_controls.html#default-group-visibility), and [snippet](https://docs.gitlab.com/ee/user/admin_area/settings/visibility_and_access_controls.html#default-snippet-visibility) visibility to Private
- [Restrict the use of public or internal projects](https://docs.gitlab.com/ee/public_access/public_access.html#restricting-the-use-of-public-or-internal-projects)
- Disable "Internal" and "Public" visibility if not needed. (link)
- IP whitelisting inside GitLab (link)
- Use rate limiting and throttling (link)

- Configure higher required lengths for SSH keys (at least 2048)
- Keep the instance updated (GitLab has frequent security releases) (link)
- [specify permitted types and lenghts for ssh keys](https://docs.gitlab.com/ee/user/admin_area/settings/visibility_and_access_controls.html#rsa-dsa-ecdsa-ed25519-ssh-keys)  Configure higher required lengths for SSH keys (at least 2048)
- Keep an eye [GitLab logs](https://docs.gitlab.com/ee/administration/logs.html) for anomalies. (link)
- [Review Audit Events](https://docs.gitlab.com/ee/administration/audit_events.html) (Starter/Bronze)
- [restrict hosting sites users can import projects from](https://docs.gitlab.com/ee/user/admin_area/settings/visibility_and_access_controls.html#import-sources)

## Sign up and Sign in restrictions

- Disable new user sign-ups by default - invite only. (link)
  - If you must have new user sign-up enabled, whitelist your email domain and blacklist the others.
- Require strong passwords (at least 12 characters in length) (link)
- Disable "Password authentication enabled for Git over HTTP(S) ()
- Enable require 2fa (link)

## Other

- use push rules to prevent secrets from being committed
- use approval rules for MRs
- use CODEOWNERS
- restrict import project sources
- 

## Network

- Use [SSL/TLS and HTTPS](https://docs.gitlab.com/omnibus/settings/ssl.html) to encrypt all GitLab network traffic.
  - GitLab Instance
  - Container Registry
  - Mattermost
  - GitLab Pages
- If possible, don’t have it internet/public facing.
- a VPN or firewall help limit exposure by restricting access (we should say why? and would this be with limiting ip access?)
