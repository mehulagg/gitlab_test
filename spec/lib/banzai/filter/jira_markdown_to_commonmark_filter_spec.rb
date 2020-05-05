# frozen_string_literal: true

require 'spec_helper'

describe Banzai::Filter::JiraMarkdownToCommonmarkFilter do
  include FilterSpecHelper

  describe 'basic jira wiki markdown constructs' do
    it 'converts basic text' do
      expect(filter('some text')).to eq("some text\n")
    end

    it 'converts text with multiple lines' do
      text = "This is text\n\n\n\n with new lines"

      expect(filter(text)).to eq("This is text\n\nwith new lines\n")
    end

    it 'converts strong and emphasis' do
      expect(filter('*strong* and _emphasis_')).to eq("**strong** and *emphasis*\n")
    end

    it 'converts superscript' do
      expect(filter('^Superscript^')).to eq("<sup>Superscript</sup>\n")
    end

    it 'converts subscript' do
      expect(filter('~Subscript~')).to eq("<sub>Subscript</sub>\n")
    end

    it 'converts strikethrough' do
      expect(filter('-Strikethrough-')).to eq("~~Strikethrough~~\n")
    end

    it 'converts headers' do
      text = <<~MD.strip_heredoc
        h1. Header 1

        h2. Header 2

        h3. Header 3

        h4. Header 4

        h5. Header 5

        h6. Header 6
      MD

      result = <<~MD.strip_heredoc
        # Header 1

        ## Header 2

        ### Header 3

        #### Header 4

        ##### Header 5

        ###### Header 6
      MD

      expect(filter(text)).to eq(result)
    end

    it 'converts quotes' do
      text = <<~MD.strip_heredoc
        bq. block quote

        {quote}this is a quote{quote}

        and

        {quote}this is a
         multiline quote{quote}
      MD

      result = <<~MD.strip_heredoc
        > block quote

        > this is a quote

        and

        > this is a\s\s
        > multiline quote
      MD

      expect(filter(text)).to eq(result)
    end

    it 'convert ordered and unordered lists' do
      text = <<~MD.strip_heredoc
        * Bullet point list item 1
        * Bullet point list Item 2

        # Number list Item 1
        # Number list item 2
      MD

      # note that Pandoc puts two extra spaces in front of the
      # unordered list.  This is valid, just unexpected
      result = <<~MD.strip_heredoc
          - Bullet point list item 1

          - Bullet point list Item 2

        <!-- end list -->

        1.  Number list Item 1

        2.  Number list item 2
      MD

      expect(filter(text)).to eq(result)
    end

    it 'converts tables' do
      text = <<~MD.strip_heredoc
        ||*Col 1 Row 1*||*Col 2 Row 1*||*Col 3 Row 1*||
        |Col 1 Row 2|Col 2 Row 2|Col 3 Row 2|
        |Col 1 Row 3|Col 2 Row 3|Col 3 Row 3|
      MD

      result = <<~MD.strip_heredoc
        | **Col 1 Row 1** | **Col 2 Row 1** | **Col 3 Row 1** |
        | --------------- | --------------- | --------------- |
        | Col 1 Row 2     | Col 2 Row 2     | Col 3 Row 2     |
        | Col 1 Row 3     | Col 2 Row 3     | Col 3 Row 3     |
      MD

      expect(filter(text)).to eq(result)
    end

    it 'converts code block without language specification (jira defaults to java)' do
      text = <<~MD.strip_heredoc
        {code}
        def method
          data = {

          }
        }
        end{code}
      MD

      result = <<~MD.strip_heredoc
        ``` java
        def method
          data = {

          }
        }
        end
        ```
      MD

      expect(filter(text)).to eq(result)
    end

    it 'converts code block both with language specification' do
      text = <<~MD.strip_heredoc
        {code:javascript}
        export function makeIssue({}) {
          const issueType = pickRandom(project.issueTypes)

          let data = {
            fields: {}
          }
        }
        end{code}
      MD

      result = <<~MD.strip_heredoc
        ``` javascript
        export function makeIssue({}) {
          const issueType = pickRandom(project.issueTypes)

          let data = {
            fields: {}
          }
        }
        end
        ```
      MD

      expect(filter(text)).to eq(result)
    end

    it 'converts inline code/monospaced ' do
      text = <<~MD.strip_heredoc
        {{inline code}}
      MD

      result = <<~MD.strip_heredoc
        `inline code`
      MD

      expect(filter(text)).to eq(result)
    end

    it 'converts external link' do
      text = <<~MD.strip_heredoc
        [External Link|https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25718]

        [https://gitlab.com|https://gitlab.com]
      MD

      result = <<~MD.strip_heredoc
        [External
        Link](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25718)

        <https://gitlab.com>
      MD

      expect(filter(text)).to eq(result)
    end
  end

  describe 'confluence style tags' do
    it 'leaves colors as is' do
      text   = 'Color - {color:#97a0af}Light Gray{color}'
      result = "Color - {color:\\#97a0af}Light Gray{color}\n"

      expect(filter(text)).to eq(result)
    end

    it 'convert panel tags into divs' do
      text = <<~MD
        text with panels

        {panel:bgColor=#e3fcef}
        Success info panel
        {panel}

        {panel:bgColor=#deebff}
        Info info panel
        {panel}

      MD
      result = <<~MD
        text with panels

        <div data-bgColor=\"#e3fcef\">

        Success info panel

        </div>

        <div data-bgColor=\"#deebff\">

        Info info panel

        </div>
      MD

      expect(filter(text)).to eq(result)
    end

    # TODO: handle mentions: https://gitlab.com/gitlab-org/gitlab/-/issues/210581
    it 'ignores the mentiones' do
      text   = '[~accountid:5e32f803e127810e82875bc1] could you check it?'
      result = "\\[\\~accountid:5e32f803e127810e82875bc1\\] could you check it?\n"

      expect(filter(text)).to eq(result)
    end
  end

  # describe 'not working' do
  #   it 'converts underline' do
  #     text = <<~MD
  #       +Underline+
  #     MD
  #     result = <<~MD
  #       Underline
  #     MD
  #
  #     expect(filter(text)).to eq(result)
  #   end
  #
  #   it 'converts smart links' do
  #     text = <<~MD.strip_heredoc
  #       internal link: [https://gitlab-jira.atlassian.net/browse/DEMO-1|https://gitlab-jira.atlassian.net/browse/DEMO-1|smart-link]
  #     MD
  #
  #     result = <<~MD.strip_heredoc
  #       internal link: [https://gitlab-jira.atlassian.net/browse/DEMO-1](https://gitlab-jira.atlassian.net/browse/DEMO-1)
  #     MD
  #
  #     expect(filter(text)).to eq(result)
  #   end
  #
  #   it 'converts citation' do
  #     expect(filter('??citation??')).to eq("<cite>citation</cite>\n")
  #   end
  # end
end
