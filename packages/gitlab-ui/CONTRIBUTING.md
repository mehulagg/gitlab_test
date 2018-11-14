# How to add a new component to gitlab-ui

1. Decide on a component you'd like to add to gitlab-ui
1. Determine and document the scenarios (different types of implementations, if any) in which this component is used in gitlab-ce/ee in an issue in gitlab-ui
1. Select a scenario that is implemented in gitlab-ce/ee that you will replace with your component
1. Create a merge request (MR) in gitlab-ui implementing your new component
   1. Be sure to name your MR `feat: <commit message>` as that is needed for our npm release CI job (don't forget to set the MR to squash commit)
   1. Create a directory and component.vue in `components/` directory
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

# Automatic documentation

We have automated as much of our documentation as possible (for example props, inherited props, links to underlying documentation, etc.) and kept manual tasks (for example name of vue-bootstrap component, slot descriptions, etc.) at an absolute minimum. The target for our documentation components and exports is to have them automatically integrated into [design.gitlab.com](https://design.gitlab.com). The main component for documentation is called `component_documentation_generator.vue`.

## Component documentation info

To add additional information to our documentation page we are using extra files which hold additional information, those have the format `(component).documentation.js` in the component directory. The following sample has a sample documentation attribute with all possibilities. All of these properties are optional.

```
export default {
  examples: glTestExamples,           // Imported Example File
  description: doc,                   // Imported Documentation file
  followsDesignSystem: true,          // If we have already fully styled this component according to design system
  bootstrapComponent: 'b-button',     // Name of the underlying vue-bootstrap component
  propsInfo: {                        // Adds description for props
    limits: {                         // Specific property name with additional info
      additionalInfo: 'The object must contain the xs, sm, md and default keys',  // Extra information that is shown in the documentation
    },
    lines: {
      validation: {                   // Specific validation for a property, atm only 'range' is supported as type
        type: 'range',
        min: 1,
        max: 3,
      },
    },
  },
  bootstrapPropsInfo: {               // Same structure as the propsInfo but to describe vue-bootstrap component properties with additional information (like enum's, slots, etc.)
    variant: {                        // Name of that property
      enum: 'buttonVariantOptions',   // Name of the used enum
    },
  },
  events: [                           // Describe events for the documentation that are emitted
    {
      event: 'click',                 // Name of the event
      description: 'Emitted when clicked on button',  // Description of the Event
    },
  ],
  slots: [                            // Available slots for this component
    {
      name: 'modal-header',           // Name of the slot
      description:
        'Entire modal header container contents. Also removes the top right X close button.',  // Description of the purpose of this slot
    },
  ]
};
```

# Contribution guidelines
Please refer to [gitlab-ce's CONTRIBUTING.md](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/CONTRIBUTING.md) for details.
