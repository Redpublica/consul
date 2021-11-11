class UsersController < ApplicationController
  has_filters %w[proposals debates budget_investments comments], only: :show

  load_and_authorize_resource
  helper_method :author?
  helper_method :valid_interests_access?

  def show
    load_filtered_activity if valid_access?
  end

  private

    def set_activity_counts
      if authorized_current_user?
        @activity_counts = ActiveSupport::HashWithIndifferentAccess.new(
                            proposals: Proposal.where(author_id: @user.id).count,
                            debates: (Setting["process.debates"] ? Debate.where(author_id: @user.id).count : 0),
                            budget_investments: (Setting["process.budgets"] ? Budget::Investment.where(author_id: @user.id).count : 0),
                            comments: only_active_commentables.count,
                            follows: @user.follows.map(&:followable).compact.count)
      else
        @activity_counts = ActiveSupport::HashWithIndifferentAccess.new(
                            proposals: Proposal.where(author_id: @user.id).not_retired.published.count,
                            debates: (Setting["process.debates"] ? Debate.where(author_id: @user.id).count : 0),
                            budget_investments: (Setting["process.budgets"] ? Budget::Investment.where(author_id: @user.id).count : 0),
                            comments: only_active_commentables.where(hidden_at: nil).count,
                            follows: @user.follows.map(&:followable).compact.count)
      end
    end

    def load_filtered_activity
      set_activity_counts
      case params[:filter]
      when "proposals" then load_proposals
      when "debates"   then load_debates
      when "budget_investments" then load_budget_investments
      when "comments" then load_comments
      when "follows" then load_follows
      else load_available_activity
      end
    end

    def load_available_activity
      if @activity_counts[:proposals] > 0
        load_proposals
        @current_filter = "proposals"
      elsif @activity_counts[:debates] > 0
        load_debates
        @current_filter = "debates"
      elsif  @activity_counts[:budget_investments] > 0
        load_budget_investments
        @current_filter = "budget_investments"
      elsif  @activity_counts[:comments] > 0
        load_comments
        @current_filter = "comments"
      elsif  @activity_counts[:follows] > 0
        load_follows
        @current_filter = "follows"
      end
    end

    def load_proposals
      if authorized_current_user?
        return @proposals = Proposal.created_by(@user).order(created_at: :desc).page(params[:page])
      else
        return @proposals = Proposal.created_by(@user).not_retired.published.order(created_at: :desc).page(params[:page])
      end
    end

    def load_debates
      @debates = Debate.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_comments
      if authorized_current_user?
        @comments = only_active_commentables.includes(:commentable).order(created_at: :desc).page(params[:page])
      else
        @comments = only_active_commentables.where(hidden_at: nil).includes(:commentable).order(created_at: :desc).page(params[:page])
      end
    end

    def load_budget_investments
      @budget_investments = Budget::Investment.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_follows
      @follows = @user.follows.group_by(&:followable_type)
    end

    def valid_access?
      @user.public_activity || authorized_current_user?
    end

    def valid_interests_access?
      @user.public_interests || authorized_current_user?
    end

    def author?(proposal)
      proposal.author_id == current_user.id if current_user
    end

    def authorized_current_user?
      @authorized_current_user ||= current_user && (current_user == @user || current_user.moderator? || current_user.administrator?)
    end

    def all_user_comments
      Comment.not_valuations.not_as_admin_or_moderator.where(user_id: @user.id)
    end

    def only_active_commentables
      disabled_commentables = []
      disabled_commentables << "Debate" unless Setting["process.debates"]
      disabled_commentables << "Budget::Investment" unless Setting["process.budgets"]
      if disabled_commentables.present?
        all_user_comments.where.not(commentable_type: disabled_commentables)
      else
        all_user_comments
      end
    end
end
