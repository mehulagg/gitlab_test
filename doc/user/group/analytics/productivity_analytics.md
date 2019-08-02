# Productivity Analytics **(PREMIUM)**
> [Introduced](https://gitlab.com/gitlab-org/gitlab-ee/issues/12079) in [GitLab Premium](https://about.gitlab.com/pricing/) 12.2.

Productivity Analytics tracks feature delivery.

For many companies, the development cycle is a blackbox and getting an estimate of how
long, on average, it takes to deliver features is an enormous endeavor.

While [Cycle Analytics](../../project/cycle_analytics.md) focuses on the entire
SDLC process, Productivity Analytics provides a way for Engineering Management to 
drill down in a systematic way  to uncover patterns and causes for success or failure on
an individual, project or group level. 

Productivity can slow down for many reasons ranging from degrading code base to quickly 
growing teams. However, before we can identify causes, we need to understand what is the 
typical lifetime of a merge request and what can be considered an outlier.

## Accessing metrics and visualizations

To access the **Productivity Analytics** page, go to **Analytics > Productivity Analytics**.


The following metrics and visualizations are available on a project or group level:

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

## Retrieving data

Users will be able to retrieve 6 months of data when they deploy the feature for the first time/ update GitLab.
Should they wish to return data for a different timespan, they can do that by running [x] in order to migrate additional data in the background.

## Permissions

The current permissions on the Productivity Analytics dashboard are:

- Only users on instances and namespaces, which are on Premium/Silver and above can view or interact with the data.
- Only users with Reporter access and above can access.

You can read more about permissions [here][permissions].
