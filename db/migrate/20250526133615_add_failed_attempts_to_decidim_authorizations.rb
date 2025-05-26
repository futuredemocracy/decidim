class AddFailedAttemptsToDecidimAuthorizations < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_authorizations, :failed_attempts, :integer, default: 0, null: false
  end
end
