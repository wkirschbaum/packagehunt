# frozen_string_literal: true
# == Schema Information
#
# Table name: projects
#
#  id           :bigint(8)        not null, primary key
#  lockfile     :text
#  name         :string           not null
#  ruby_version :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Project < ApplicationRecord
  def project_name
    name.split('/').last
  end

  def organisation_name
    name.split('/').first
  end
end
