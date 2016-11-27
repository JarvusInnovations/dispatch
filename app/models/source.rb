# == Schema Information
#
# Table name: sources
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Source < ActiveRecord::Base
  has_many :opportunities, dependent: :nullify

  default_scope -> { order('LOWER(name)') }
end
