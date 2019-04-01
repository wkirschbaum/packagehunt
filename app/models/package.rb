# frozen_string_literal: true

# == Schema Information
#
# Table name: packages
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  version    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint(8)        not null
#
# Indexes
#
#  index_packages_on_project_id  (project_id)
#

class Package < ApplicationRecord
  belongs_to :project

  def project_name
    project.name
  end

  def as_json(*)
    super.except("created_at", "updated_at").tap do |hash|
      hash["project_name"] = project_name
    end
  end
end
