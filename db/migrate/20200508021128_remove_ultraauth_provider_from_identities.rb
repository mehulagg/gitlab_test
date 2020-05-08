# frozen_string_literal: true

class RemoveUltraauthProviderFromIdentities < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute "DELETE FROM identities WHERE provider = 'ultraauth'"
  end

  def down
  end
end
