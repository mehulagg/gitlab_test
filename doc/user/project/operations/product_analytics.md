# Product Analytics

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/27730) in GitLab 13.0.

## Introduction

GitLab allows you to go from plan to getting feedback. Feedback isn't just observability but also knowing how people use your product.
Product Analytics is using events sent from your application to know how they are using it.

## Pages

You can find Product Analytics in the Operations menu of a project. It consists of:

1. Index page that shows the recent events and a total count.
1. Users page that shows what timezone, language, screen, etc. your users use.
1. Actity page that shows how many events have happend in the last 30 days.
1. Test page that sends a sample event.
1. Example page that contains the code to implement in your application.

## Based on Snowplow

[Snowplow](https://github.com/snowplow/snowplow) has the best open source event tracker. With this MR you can receive and analyze the Snowplow data inside GitLab.

## Rate limit

This is a very minimal first iteration, it will allow us to proceed further.
Right now there is a strict **100 events per minute rate limit** per customer. This is to prevent the events table in the database from growing too fast. If people start using this in earnest we need to figure out how to scale this.
