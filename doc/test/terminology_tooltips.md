# Test terminology tooltips

## Tooltips (hover)

_Text-styled question mark:_

- To start working locally on an existing remote repository
<span data-toggle="tooltip" data-html="true" title="<em>Remote repository</em> refers to the files in GitLab. The same files in your computer are called <em>local copy</em>.">
<span style="pointer-events: none; opacity: .5;" type="button" disabled><i class="fa fa-question-circle" aria-hidden="true"></i></span>
</span>
clone it with the command `git clone <repository path>`.

_Text-only highlighted in gray:_

- To start working locally on an existing
<span data-toggle="tooltip" data-html="true" title="<em>Remote repository</em> refers to the files in GitLab. The same files in your computer are called <em>local copy</em>.">
<span style="pointer-events: none; opacity: .5;" type="button" disabled> remote repository </span>
</span>
clone it with the command `git clone <repository path>`.

## Popover (click)

_Text-styled question mark highlighted in gray, click on the button to dismiss:_

- To start working locally on an existing remote repository <a style="color: gray;" type="button" data-container="body" data-toggle="popover" data-placement="top" data-html="true" data-content="Your files in GitLab. In your computer, they're called <em>local repository</em>."><i class="fa fa-question-circle" aria-hidden="true"></i></a>, clone it with the command `git clone <repository path>`.

_Link-styled question mark, click on the page to dismiss:_

- To start working locally on an existing remote repository <a tabindex="0" type="button" data-container="body" data-toggle="popover" data-placement="top" data-trigger="focus" data-html="true" data-content="Your files in GitLab. In your computer, they're called <em>local repository</em>."><i class="fa fa-question-circle" aria-hidden="true"></i></a>, clone it with the command `git clone <repository path>`.
