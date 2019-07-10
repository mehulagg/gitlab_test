# frozen_string_literal: true

class UserSerializer < BaseSerializer
  entity UserEntity

  def represent(user, opts = {}, entity = nil)
    if params[:merge_request_iid]
      merge_request = opts[:project].merge_requests.find_by_iid(params[:merge_request_iid])
      super(user, opts.merge(merge_request: merge_request), UserForMergeRequestEntity)
    else
      super
    end
  end
end
