# frozen_string_literal: true

class QaSessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.find_by(username: params[:username])

    if user && user.valid_password?(params[:password])
      sign_in(user)
      redirect_to after_sign_in_path_for(user)
    else
      render_403
    end
  end
end
