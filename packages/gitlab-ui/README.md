# gitlab-ui

`gitlab-ui` is a UI component library written in [Vue.js](https://vuejs.org).
See https://gitlab-org.gitlab.io/gitlab-ui/ for documentation.


## Prerequisites

Make sure you have [Node](https://nodejs.org/en/) 8.x (LTS) and [Yarn](https://yarnpkg.com/) 1.2 or newer.

## Quick start

```sh
# Clone the project
git clone git@gitlab.com:gitlab-org/gitlab-ui.git

# Install all the dependencies of the project
yarn # or yarn install

# Build and launch storybook to see the components in the browser
yarn storybook
```

Go to http://localhost:9001/

## Installation

```sh
npm install @gitlab-org/gitlab-ui
```

## Configuring application.css

This project uses GitLab CE's master branch `application.css` for styles. If you'd like to configure a different css file to load instead of the default `application.css`, you may set the `CSS_URL` environment variable with the css path before building storybook.

```sh
CSS_URL=https://example.com/application.css yarn storybook
```

## Contributing guide

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to add new components and contribute in general.
