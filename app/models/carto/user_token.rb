require 'active_record'
require_dependency 'carto/db/sanitize'

module Carto
  class UserToken < ActiveRecord::Base

    belongs_to :user_table
    validates :token, uniqueness: true

    before_validation :generate_token

    def generate_token
      self.token ||= Carto::UserService.make_token
    end
  end
end
