# Productivity Analytics **(PREMIUM)**
> [Introduced](https://gitlab.com/gitlab-org/gitlab-ee/issues/12079) in [GitLab Premium](https://about.gitlab.com/pricing/) 12.2.

Track development velocity with Productivity Analytics.

For many companies, the development cycle is a blackbox and getting an estimate of how
long, on average, it takes to deliver features is an enormous endeavor.

While [Cycle Analytics](../../project/cycle_analytics.md) focuses on the entire
SDLC process, Productivity Analytics provides a way for Engineering Management to 
drill down in a systematic way to uncover patterns and causes for success or failure at
an individual, project or group level. 

Productivity can slow down for many reasons ranging from degrading code base to quickly 
growing teams. In order to investigate, department or team leaders can start by visualizing the contributions to their git repos.

- **Visualize the typical Merge Request (MR) lifetime and statistics**
    - The below histogram shows the distribution of the time lapsed between creating and merging MRs. In the below example, the values are centered around [x], with [x] outliers which took more than [x] days.
[screenshot of the first chart]

- **Drill down into the most time consuming MRs**
    - Users can select a number of outliers and filter down all subsequent charts in order to investigate potential causes. In the below example, we see that the MRs that took more than [x] days, generally have longer review time as shown by 'Time from First Comment to Last Commit'. We also see that these MRs have more LOCs and number of commits. This seems to imply that engineers should break down their code more in order to speed up review.
[screenshot of a selected bar with the rest of charts]

- **Measure velocity over time**
    - Users can see how each metric in the histograms trends over time in order to observe progress. MRs together with their date of completion are visualized as dots, together with a line representing last 30 days moving median thereof. In the below example, we can see that between [x] and [y], we have decreased the time required to merge at the same time as the median LOC per MR. 
[screenshot of a the scatterplot chart if we have it with a user selecting from a dropdown]

- **Filter by group, project, author, label, milestone or specific date range**
    - Users can filter down, for example, to the MRs of a specific author in a group or project during a milestone or specific date range.
[screenshot of us selecting an author, milestone, group and project]

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

Users can retrieve six months of data when they deploy Cycle Analytics for the first time.

The charts are updated every [x] hours with jobs triggered at [x] UTC.

To retrieve data for a different time span:

<then add the steps here>

## Permissions

The **Productivity Analytics** dashboard can be accessed only:

- On GitLab instances and namespaces on
  [Premium or Silver tier](https://about.gitlab.com/pricing/) and above.
- By users with [Reporter access](../../permissions.md) and above.
