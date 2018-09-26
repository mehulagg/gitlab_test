# How to add a new component to gitlab-ui

1. Decide on a component you'd like to add to gitlab-ui
1. Determine and document the scenarios (different types of implementations, if any) in which this component is used in gitlab-ce/ee in an issue in gitlab-ui
1. Select a scenario that is implemented in gitlab-ce/ee that you will replace with your component
1. Create a merge request (MR) in gitlab-ui implementing your new component
   1. Be sure to name your MR `feat: <commit message>` as that is needed for our npm release CI job (don't forget to set the MR to squash commit)
   1. Create component.vue in `components/` directory
   1. Create a story `component.js` in stories/ directory
   1. Import your story to `.storybook/config.js`
   1. Import your component to `index.js`
   1. Create documentation.md in `documentation/` directory
   1. Run the manual CI job (update_snapshots) to generate your image snapshots for diffing

1. Create a MR to gitlab-ce/ee to replace the scenario implementation (if any) that you previously selected
1. Update your package.json dependency reference of @gitlab-org/gitlab-ui to the URL output of the upload_artifacts ci job in your gitlab-ui MR
1. Run yarn install to make sure that the gitlab-ui contents are installed
1. If your new component is used on every page, import to app/assets/javascripts/commons/gitlab_ui.js so that your component is globally registered
1. Once you've verified that your integration MR to gitlab-ce/ee is working, assign a maintainer to review both gitlab-ui and gitlab-ce/ee MRs (a list of maintainers can be found on the [team](https://about.gitlab.com/team/) page)
1. Maintainer will merge the gitlab-ui MR, the publish CI job will automatically create a new release on NPM
1. (You or maintainer) will update your integration MR package.json dependency reference to the newly released gitlab-ui version
1. Maintainer will merge the integration MR

# Contribution guidelines
Please refer to [gitlab-ce's CONTRIBUTING.md](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/CONTRIBUTING.md) for details.
