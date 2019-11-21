# How to run Jenkins in development environment (on OSX)

This is a step by step guide on how to set up Jenkins on your locale machine and connect it your GitLab instance. GitLab is triggering webhooks on Jenkins and Jenkins is connecting back to GitLab over the API. By running both applications on the same machine, we can make sure they are able to access each other.

## Install Jenkins

Jenkins can be installed with Homebrew

```
brew install jenkins
brew services start jenkins
```

## Configure GitLab

GitLab does not allow requests to localhost or the local network. When running Jenkins on your local machine, you need to turn this off.

1. On your GitLab instance, go to the admin area > Settings > Network
1. Expand `Outbound requests` and make sure `Allow requests to the local network from web hooks and services` and `Allow requests to the local network from system hooks` is active

Read more about it [here](https://docs.gitlab.com/ee/security/webhooks.html)

Jenkins uses the GitLab API and needs an access token.

1. On your GitLab instance, when you are logged in go to Settings > Access Tokens
1. Create a personal access token with access to the API. Remember the token

## Configure Jenkins

Set up your GitLab API connection

1. Make sure the GitLab plugin is installed on Jenkins. you can manage plugins in Manage Jenkins > Manage Plugins
1. Set up the GitLab connection: Go to Manage Jenkins > Configure System, find the GitLab section and check the `Enable authentication for '/project' end-point` box
1. Add your credentials by pressing the `Add` button and choose `Jenkins Credential Provider`
1. Choose "GitLab API token" as kind.
1. Paste your access token and hit `Add`
1. Choose your credentials from the dropdown menu
1. Add your GitLab host URL. Normally `http://localhost:3000/`
1. Save Settings

See also [GitLab documentation about Jenkins CI](https://docs.gitlab.com/ee/integration/jenkins.html)

## Configure Jenkins Project

Set up the Jenkins project you are going to run your build on

1. On your Jenkins instance, go to `New Item`
1. Pick a name, choose `Pipeline` and press `ok`
1. Choose your GitLab connection from the dropdown
1. Check `Build when a change is pushed to GitLab`
1. Check the boxes `Accepted Merge Request Events` and `Closed Merge Request Events`
1. Updating the status on GitLab has to be done by the pipeline skript. Add GitLab update steps like in the example below

**Example Pipeline Skript:**

```
pipeline {
   agent any

   stages {
      stage('gitlab') {
         steps {
            echo 'Notify GitLab'
            updateGitlabCommitStatus name: 'build', state: 'pending'
            updateGitlabCommitStatus name: 'build', state: 'success'
         }
      }
   }
}
```

## Configure your GitLab project

To activate the Jenkins service you have to have a license for Starter or higher.

1. Go to your project > Settings > Integrations > Jenkins CI
1. Check the `Active` box and the triggers for `Push` and `Merge request`
1. Fill in your Jenkins host, project name, username and password and press `Test settings and save changes`

## Testing your setup

Make a change in your repository and open an MR. In your Jenkins project it should have triggered a new build and on your MR, there should be a widget saying "Pipeline #NUMBER passed". It will also include a link to your Jenkins build.
