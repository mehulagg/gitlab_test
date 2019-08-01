# Productivity Analytics

For many companies, the development cycle is a blackbox and getting an estimate of how long on average it takes to deliver features is an enormous endeavor. While we are focusing on the entire SDLC process in [cycle analytics](https://docs.gitlab.com/ee/user/project/cycle_analytics.html), we also want to provide a way for Engineering Management to drill down in a systematic way in order to uncover patterns and causes for success or failure on an individual, project or group level. Productivity can slow down for many reasons ranging from degrading code base to quickly growing teams, but before we can identify causes, we need to get an understanding of what is the typical lifetime of a merge request and what can be considered an outlier.

## Overview

You can find the Productivity Analytics page in the main navigation bar under **Analytics ➔ Productivity Analytics** tab.

![Productivity Analytics landing page](\To add an image when we have it on gitlab.com?/).

We currently have the below metrics and visualizations, which users can interact with on a project or group level:

- **A histogram showing the number of merge request that took a specified number of days to merge after creation** (in days)
  - Users can filter down all subsequent chart by selecting specific column(s)
  
- **A histogram showing a breakdown of the time taken to merge a request** (in hours)
  - Users can select from a dropdown one of the following intervals:
    - Time from First Commit until First Comment
    - Time from First Comment until Last Commit
    - Time from Last Commit to Merge
    
- **A histogram showing the size/complexity of a merge request**
  - Users can select from a dropdown one of the following intervals:
    - Number of commits per MR
    - Number of LOCs per commit
    - Number of files touched 
    
- **A scatterplot with a moving median **
  - Users can see trends with specific MRs or 30 day moving median for any of the below metrics:
    - Time to Merge
    - Time from First Commit until First Comment
    - Time from First Comment until Last Commit
    - Time from Last Commit to Merge
    - Number of commits per MR
    - Number of LOCs per commit
    - Number of files touched 
    - 
- **A table showing a list of merge requests with their respective times and size metrics**
  - Users can sort by:
    - Time to Merge
    - Time from First Commit until First Comment
    - Time from First Comment until Last Commit
    - Time from Last Commit to Merge
    - Number of commits per MR
    - Number of LOCs per commit
    - Number of files touched 

## Permissions

The current permissions on the Productivity Analytics dashboard are:

- Only users on instances and namespaces, which are on Premium/Silver and above can view or interact with the data.
- Only users with Reporter access and above can access.

You can read more about permissions [here][permissions].
