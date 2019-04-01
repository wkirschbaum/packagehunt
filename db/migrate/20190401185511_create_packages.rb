# frozen_string_literal: true

class CreatePackages < ActiveRecord::Migration[5.2]
  def change
    create_table :packages do |t|
      t.string :name, null: false
      t.string :version, null: false
      t.references :project, null: false

      t.timestamps
    end
  end
end
