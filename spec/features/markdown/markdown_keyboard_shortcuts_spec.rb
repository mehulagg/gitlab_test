# frozen_string_literal: true

require 'spec_helper'

describe 'Markdown keyboard shortcuts', :js do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue) { create(:issue, project: project) }

  before do
    project.add_maintainer(user)
    sign_in(user)
    visit project_issue_path(project, issue)
  end

  it 'allows bold formatting with control+b' do
    find('#note-body').send_keys(:control, 'b')

    expect(textarea_content).to eq '****'
    expect(cursor_position).to eq(2)
  end

  it 'allows italic formatting with control+i' do
    find('#note-body').send_keys(:control, 'i')

    expect(textarea_content).to eq '**'
    expect(cursor_position).to eq(1)
  end

  it 'allows link insertion with control+k' do
    find('#note-body').send_keys(:control, 'k')

    expect(textarea_content).to eq '[](url)'
    expect(selection_start).to eq(3)
    expect(selection_end).to eq(6)
  end

  def textarea_content
    find('#note-body')[:value]
  end

  def cursor_position
    selection_start
  end

  def selection_start
    page.evaluate_script('document.querySelector("#note-body").selectionStart')
  end

  def selection_end
    page.evaluate_script('document.querySelector("#note-body").selectionEnd')
  end
end
