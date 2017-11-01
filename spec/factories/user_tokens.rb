require 'helpers/unique_names_helper'

include UniqueNamesHelper

FactoryGirl.define do
  factory :carto_user_token, class: Carto::UserToken do
    user_table { create(:carto_user_table) }
    token { unique_name('user_token') }
  end
end
