# Hardening self-managed GitLab instances

## Visibility and Access

- Set default project visibility to private (link)
- Disable "Internal" and "Public" visibility if not needed. (link)
- IP whitelisting inside GitLab (link)
- Use rate limiting and throttling (link)
- Use TLS/HTTPS everywhere to encrypt network traffic. (link)
- Configure higher required lengths for SSH keys (at least 2048)
- Keep the instance updated (GitLab has frequent security releases) (link)
- Keep an eye on audit logs and gitlab logs for anomalies. (link)
- If possible, don’t have it internet/public facing.
- a VPN or firewall help limit exposure by restricting access (we should say why? and would this be with limiting ip access?)

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
