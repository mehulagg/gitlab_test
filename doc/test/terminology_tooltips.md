# Test terminology tooltips

## Tooltips (hover)

_Text-styled question mark:_

- To start working locally on an existing <span onmouseover="this.style.textDecoration='underline';" onmouseout="this.style.textDecoration='none';" data-toggle="tooltip" data-html="true" title="Your files in GitLab. In your computer, they're called <em>local repository</em>."><span style="pointer-events: none; opacity: .5;" type="button" disabled>remote repository <i class="fa fa-question-circle" aria-hidden="true"></i></span></span>, clone it with the command `git clone <repository path>`.

_Text-only highlighted in gray:_

- To start working locally on an existing <span onmouseover="this.style.textDecoration='underline';" onmouseout="this.style.textDecoration='none';" data-toggle="tooltip" data-html="true" title="Your files in GitLab. In your computer, they're called <em>local repository</em>."><span style="pointer-events: none; opacity: .5;" type="button" disabled>remote repository</span></span>, clone it with the command `git clone <repository path>`.

## Popover (click)

_Text-styled question mark highlighted in gray, click on the button to dismiss:_

- To start working locally on an existing <a onmouseover="this.style.textDecoration='underline';" onmouseout="this.style.textDecoration='none';" style="color: gray;" type="button" data-container="body" data-toggle="popover" data-placement="top" data-html="true" data-content="Your files in GitLab. In your computer, they're called <em>local repository</em>.">remote repository <i class="fa fa-question-circle" aria-hidden="true"></i></a>, clone it with the command `git clone <repository path>`.

_Link-styled question mark, click on the page to dismiss:_

- To start working locally on an existing <a tabindex="0" type="button" data-container="body" data-toggle="popover" data-placement="top" data-trigger="focus" data-html="true" data-content="Your files in GitLab. In your computer, they're called <em>local repository</em>.">remote repository <i class="fa fa-question-circle" aria-hidden="true"></i></a>, clone it with the command `git clone <repository path>`.

_Link-styled text without the question mark, click on the page to dismiss:_

- To start working locally on an existing <a style="color: gray;" tabindex="0" type="button" data-container="body" data-toggle="popover" data-placement="top" data-trigger="focus" data-html="true" data-content="Your files in GitLab. In your computer, they're called <em>local repository</em>.">remote repository</a>, clone it with the command `git clone <repository path>`.
