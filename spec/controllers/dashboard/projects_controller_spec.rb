# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::ProjectsController do
  include ExternalAuthorizationServiceHelpers

  describe '#index' do
    context 'user not logged in' do
      it_behaves_like 'authenticates sessionless user', :index, :atom
    end

    context 'user logged in' do
      let_it_be(:user) { create(:user) }
      let_it_be(:project) { create(:project) }
      let_it_be(:project2) { create(:project) }

      before_all do
        project.add_developer(user)
        project2.add_developer(user)
      end

      before do
        sign_in(user)
      end

      context 'external authorization' do
        it 'works when the external authorization service is enabled' do
          enable_external_authorization_service_check

          get :index

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      it 'orders the projects by last activity by default' do
        project.update!(last_repository_updated_at: 3.days.ago, last_activity_at: 3.days.ago)
        project2.update!(last_repository_updated_at: 10.days.ago, last_activity_at: 10.days.ago)

        get :index

        expect(assigns(:projects)).to eq([project, project2])
      end

      context 'project sorting' do
        it_behaves_like 'set sort order from user preference' do
          let(:sorting_param) { 'created_asc' }
        end
      end

      context 'with search and sort parameters' do
        render_views

        shared_examples 'search and sort parameters' do |sort|
          it 'returns a single project with no ambiguous column errors' do
            get :index, params: { name: project2.name, sort: sort }

            expect(response).to have_gitlab_http_status(:ok)
            expect(assigns(:projects)).to eq([project2])
          end
        end

        %w[latest_activity_desc latest_activity_asc stars_desc stars_asc created_desc].each do |sort|
          it_behaves_like 'search and sort parameters', sort
        end
      end
    end
  end

  context 'json requests' do
    render_views

    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    describe 'GET /projects.json' do
      before do
        get :index, format: :json
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'GET /starred.json' do
      subject { get :starred, format: :json }

      let(:projects) { create_list(:project, 2, creator: user) }

      before do
        allow(Kaminari.config).to receive(:default_per_page).and_return(1)

        projects.each do |project|
          project.add_developer(user)
          create(:users_star_project, project_id: project.id, user_id: user.id)
        end
      end

      it 'returns success' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
      end

      it 'paginates the records' do
        subject

        expect(assigns(:projects).count).to eq(1)
      end
    end
  end

  context 'atom requests' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    describe '#index' do
      context 'project pagination' do
        let(:projects) { create_list(:project, 2, creator: user) }

        before do
          allow(Kaminari.config).to receive(:default_per_page).and_return(1)

          projects.each do |project|
            project.add_developer(user)
          end
        end

        it 'does not paginate projects, even if normally restricted by pagination' do
          get :index, format: :atom

          expect(assigns(:events).count).to eq(2)
        end
      end
    end
  end
end
