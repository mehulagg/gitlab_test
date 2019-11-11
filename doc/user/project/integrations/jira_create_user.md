# Creating a Jira user for GitLab

GitLab integration requires write access to the relevant Jira projects. To achieve that, you must create a Jira user with access to those projects.

In this example, you will create a user named `gitlab` and add it to a new group named `gitlab-developers`.

1. Log in to your Jira instance as an administrator.

1. Go to **Administration** (gear icon) **> User management** and click **Create user**.

   ![Jira user management link](img/jira_user_management_link.png)

1. Create the `gitlab` user.
    1. Complete the following fields of the **Create new user** form:
        - Email address
            - Example: `example@gitlab.com`
        - Full name
            - Example: `gitlab`
        - Username
            - Example: `gitlab`
        - Password
            - Ensure the password complies with your organization's security policy.
    1. Check the **Jira Software** checkbox.
    1. Click **Create user**.
    Record the username and password as you will need these in a later procedure.
   ![Jira create new user](img/jira_create_new_user.png)

1. Create a `gitlab-developers` group.
   - Go to the **Groups** tab on the left, and select **Add group**.
   - Enter a group name.
     - Example: `gitlab-developers`
   - Click **Add group**.
   ![Jira create new user](img/jira_create_new_group.png)

1. Add the `gitlab` user to the `gitlab-developers` group.
    - In the `gitlab-developers` line, click **Edit members**. The `gitlab-developers` group should be listed in the leftmost box as the selected group.
    - Enter `gitlab` in the **Add members to selected group(s)** input box, then click **Add selected users**.
    ![Jira added user to group](img/jira_added_user_to_group.png)
1. Create a **Permission Scheme** to grant the new group 'write' access.
    - Go to **Administration** (gear icon) **> Issues**.
    - Click **Permission schemes** in the sidebar.
    - Click **Add permission scheme**
    - Enter a **Name** and, optionally, a **Description**.
    Once your permission scheme is created, you'll be taken back to the permissions scheme list.
1.  Add the `gitlab-developers` group to the new permissions scheme.
    - Find your new permissions scheme in the list and click **Permissions**.
    - In the **Administer Projects** row, click **Edit**.
    - In the dialog box, select **Group**, then select `gitlab-developers` from the dropdown.
    - Click **Grant**.

   ![Jira group access](img/jira_group_access.png)
