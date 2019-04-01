# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :language, null: false
      t.string :language_version

      t.timestamps
    end
  end
end
