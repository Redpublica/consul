class User::Exporter
  require "csv"

  def initialize(users)
    @users = users
    @proposals = Proposal.all
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @users.each { |user| csv << csv_values(user) }
    end
  end

  private

    def headers
      [
        I18n.t("admin.users.index.export_list.id"),
        I18n.t("admin.users.index.export_list.email"),
        I18n.t("admin.users.index.export_list.username"),
        I18n.t("admin.users.index.export_list.created_at"),
        I18n.t("admin.users.index.export_list.confirmed_at"),
        I18n.t("admin.users.index.export_list.last_sign_in"),
        I18n.t("admin.users.index.export_list.gender"),
        I18n.t("admin.users.index.export_list.educational_level"),
        I18n.t("admin.users.index.export_list.date_of_birth"),
        I18n.t("admin.users.index.export_list.proposals"),
        I18n.t("admin.users.index.export_list.comments"),
        I18n.t("admin.users.index.export_list.proposals_votes"),
      ]
    end

    def csv_values(user)
      [
        user.id.to_s,
        user.email,
        user.username.to_s,
        user.created_at,
        user.confirmed_at,
        user.last_sign_in_at,
        gender(user),
        educational_level(user),
        user.date_of_birth,
        user.proposals.count,
        user.comments.count,
        proposals_votes(user)
      ]
    end

    def gender(user)
      if user.gender.present?
        I18n.t("activemodel.models.user.gender.#{user.gender}")
      else
        ""
      end
    end

    def educational_level(user)
      if user.educational_level.present?
        I18n.t("activemodel.models.user.educational_levels.values.#{user.educational_level}")
      else
        ""
      end
    end

    def proposals_votes(user)
      user.proposal_votes(@proposals).count
    end
end
