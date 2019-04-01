# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id               :bigint(8)        not null, primary key
#  language         :string           not null
#  language_version :string
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Project < ApplicationRecord
end
