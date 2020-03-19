---
type: reference, howto
---

# New Pages website from a forked sample

To get started with GitLab Pages from a sample website, the easiest
way to do it is by using one of the [bundled templates](pages_bundled_template.md).
If you don't find one that suits your needs, you can opt by
forking (copying) a [sample project from the most popular Static Site Generators](https://gitlab.com/pages).

<table class="borderless-table center fixed-table middle width-80">
  <tr>
    <td style="width: 30%"><img src="../img/icons/fork.png" alt="Fork" class="image-noshadow half-width"></td>
    <td style="width: 10%">
      <strong>
        <i class="fa fa-angle-double-right" aria-hidden="true"></i>
      </strong>
    </td>
    <td style="width: 30%"><img src="../img/icons/terminal.png" alt="Deploy" class="image-noshadow half-width"></td>
    <td style="width: 10%">
      <strong>
        <i class="fa fa-angle-double-right" aria-hidden="true"></i>
      </strong>
    </td>
    <td style="width: 30%"><img src="../img/icons/click.png" alt="Visit" class="image-noshadow half-width"></td>
  </tr>
  <tr>
    <td><em>Fork an example project</em></td>
    <td></td>
    <td><em>Deploy your website</em></td>
    <td></td>
    <td><em>Visit your website's URL</em></td>
  </tr>
</table>

**<i class="fa fa-youtube-play youtube" aria-hidden="true"></i> Watch a [video tutorial](https://www.youtube.com/watch?v=TWqh9MtT4Bg) with all the steps below.**

1. [Fork](../../../../gitlab-basics/fork-project.md) a sample project from the [GitLab Pages examples](https://gitlab.com/pages) group.
1. From the left sidebar, navigate to your project's **CI/CD > Pipelines**
   and click **Run pipeline** to trigger GitLab CI/CD to build and deploy your
   site to the server.
1. When the pipeline finishes successfully, find the link to visit your
   website from your project's **Settings > Pages**. It can take approximately
   30 minutes to be deployed.

If your project is on GitLab.com, the URL will be
`https://<user-or-group-name>.gitlab.io/<project-name>`.

If your project is on a self-managed instance, the URL will be
`https://<user-or-group-name>.<your-instance-domain>/<project-name>`.

[Learn more about how the domain names are determined](../getting_started_part_one.md#gitlab-pages-default-domain-names).

If you don't intend to contribute to the project you forked, remove the fork
relationship by navigating to your project's **Settings > General**, expanding **Advanced settings**, and scrolling down to **Remove fork relationship**:

![remove fork relationship](../img/remove_fork_relationship.png)
