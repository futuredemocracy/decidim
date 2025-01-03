class AddUniqueConstraintToReferencePrefixInDecidimOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_index :decidim_organizations, :reference_prefix, unique: true
  end
end
