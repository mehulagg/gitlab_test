# frozen_string_literal: true

module EE
  module BoardsHelper
    extend ::Gitlab::Utils::Override

    def parent
      @group || @project
    end

    override :board_list_data
    def board_list_data
      super.merge(list_milestone_path: board_milestones_path(board, :json),
                  list_assignees_path: board_users_path(board, :json))
    end

    override :board_data
    def board_data
      show_feature_promotion = (@project && show_promotions? &&
                                (!@project.feature_available?(:multiple_project_issue_boards) ||
                                 !@project.feature_available?(:scoped_issue_board) ||
                                 !@project.feature_available?(:issue_board_focus_mode)))

      data = {
        recent_boards_endpoint: recent_boards_path,
        board_milestone_title: board.milestone&.name,
        board_milestone_id: board.milestone_id,
        board_assignee_username: board.assignee&.username,
        label_ids: board.label_ids,
        labels: board.labels.to_json(only: [:id, :title, :color, :text_color] ),
        board_weight: board.weight,
        focus_mode_available: parent.feature_available?(:issue_board_focus_mode),
        weight_feature_available: parent.feature_available?(:issue_weights).to_s,
        show_promotion: show_feature_promotion
      }

      super.merge(data)
    end

    def recent_boards_path
      parent.is_a?(Group) ? recent_group_boards_path(@group) : recent_project_boards_path(@project)
    end

    def current_board_json
      board = @board || @boards.first

      board.to_json(
        only: [:id, :name, :milestone_id, :assignee_id, :weight, :label_ids],
        include: {
          milestone: { only: [:id, :title, :name] },
          assignee: { only: [:id, :name, :username], methods: [:avatar_url] },
          labels: { only: [:title, :color, :id] }
        }
      )
    end

    override :boards_link_text
    def boards_link_text
      if parent.multiple_issue_boards_available?
        s_("IssueBoards|Boards")
      else
        s_("IssueBoards|Board")
      end
    end
  end
end
