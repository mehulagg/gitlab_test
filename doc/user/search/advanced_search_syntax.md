---
stage: Create
group: Editor
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers"
type: reference
---

# Advanced Search Syntax **(STARTER)**

> - Introduced in [GitLab Enterprise Starter](https://about.gitlab.com/pricing/) 9.2

NOTE: **GitLab.com availability:**
Advanced Search (powered by Elasticsearch) is enabled for Bronze and above on GitLab.com since 2020-07-10.

Use advanced queries for more targeted search results.

This is the user documentation. To install and configure Elasticsearch,
visit the [administrator documentation](../../integration/elasticsearch.md).

## Overview

The Advanced Search Syntax is a subset of the
[Advanced Search](advanced_global_search.md), which you can use if you
want to have more specific search results.

Advanced Search only supports searching the [default branch](../project/repository/branches/index.md#default-branch).

## Use cases

Let's say for example that the product you develop relies on the code of another
product that's hosted under some other group.

Since under your GitLab instance there are hosted hundreds of different projects,
you need the search results to be as efficient as possible. You have a feeling
of what you want to find (e.g., a function name), but at the same you're also
not so sure.

In that case, using the advanced search syntax in your query will yield much
better results.

## Using the Advanced Search Syntax

The Advanced Search Syntax supports fuzzy or exact search queries with prefixes,
boolean operators, and much more.

Full details can be found in the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/5.3/query-dsl-simple-query-string-query.html#_simple_query_string_syntax), but
here's a quick guide:

- Searches look for all the words in a query, in any order - e.g.: searching
  issues for `display bug` will return all issues matching both those words, in any order.
- To find the exact phrase (stemming still applies), use double quotes: `"display bug"`
- To find bugs not mentioning display, use `-`: `bug -display`
- To find a bug in display or sound, use `|`: `bug display | sound`
- To group terms together, use parentheses: `bug | (display +sound)`
- To match a partial word, use `*`: `bug find_by_*`
- To find a term containing one of these symbols, use `\`: `argument \-last`

### Syntax search filters

The Advanced Search Syntax also supports the use of filters. The available filters are:

- filename: Filters by filename. You can use the glob (`*`) operator for fuzzy matching.
- path: Filters by path. You can use the glob (`*`) operator for fuzzy matching.
- extension: Filters by extension in the filename. Please write the extension without a leading dot. Exact match only.

To use them, simply add them to your query in the format `<filter_name>:<value>` without
 any spaces between the colon (`:`) and the value.

Examples:

- Finding a file with any content named `hello_world.rb`: `* filename:hello_world.rb`
- Finding a file named `hello_world` with the text `whatever` inside of it: `whatever filename:hello_world`
- Finding the text 'def create' inside files with the `.rb` extension: `def create extension:rb`
- Finding the text `sha` inside files in a folder called `encryption`: `sha path:encryption`
- Finding any file starting with `hello` containing `world` and with the `.js` extension: `world filename:hello* extension:js`

#### Excluding filters

[Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/31684) in GitLab Starter 13.3.

Filters can be inversed to **filter out** results from the result set, by prefixing the filter name with a `-` (hyphen) character, such as:

- `-filename`
- `-path`
- `-extension`

Examples:

- Finding `rails` in all files but `Gemfile.lock`: `rails -filename:Gemfile.lock`
- Finding `success` in all files excluding `.po|pot` files: `success -filename:*.po*`
- Finding `import` excluding minified JavaScript (`.min.js`) files: `import -extension:min.js`
- Finding `docs` for all files outside the `docs/` folder: `docs -path:docs/`
