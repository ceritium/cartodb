# coding: UTF-8
require_relative '../../spec_helper'
require 'models/user_table_shared_examples'

describe Carto::UserToken do
  before(:all) do
    @user = create_user(email: 'admin@cartotest.com', username: 'admin', password: '123456')
    @carto_user = Carto::User.find(@user.id)

    @carto_user_table = FactoryGirl.create(:carto_user_table, user: @carto_user)
  end

  after(:all) do
    @carto_user_table.destroy
    @carto_user.destroy
  end

  describe 'token' do
    it 'generate a token if it is empty' do
      user_token = FactoryGirl.build(:carto_user_token, token: nil, user_table: @carto_user_table)
      user_token.save!
      expect(user_token.token).to be_present
    end

    it 'respect previews token' do
      user_token = FactoryGirl.build(:carto_user_token, token: 'foo', user_table: @carto_user_table)
      user_token.save!
      expect(user_token.token).to be_present
    end
  end
end
