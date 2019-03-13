# frozen_string_literal: true

shared_examples 'remove_due_date action not available' do
  it 'does not remove the due date' do
    add_note("/remove_due_date")

    expect(page).not_to have_content 'Commands applied'
    expect(page).not_to have_content '/remove_due_date'
  end
end

shared_examples 'remove_due_date action available and due date can be removed' do
  it 'removes the due date accordingly' do
    add_note('/remove_due_date')

    expect(page).not_to have_content '/remove_due_date'
    expect(page).to have_content 'Commands applied'

    visit current_url

    page.within '.due_date' do
      expect(page).to have_content 'No due date'
    end
  end
end
