module QA
  context 'Geo', :orchestrated, :geo do
    describe 'Database updates' do
      # create project and issue(s) on primary
      # check replicated on secondary
      # add, delete, change issues on primary
      # check for updates on secondary
  end