# encoding: utf-8

require_relative '../../../spec_helper'

describe Carto::Api::UserTokensController do
  before(:all) do
    @user = FactoryGirl.create(:valid_user)
    @table = create_table(user_id: @user.id)
  end

  before(:each) do
    bypass_named_maps
  end

  after(:all) do
    @user.destroy
  end

  let(:params) do
    { api_key: @user.api_key, table_id: @table.name, user_domain: @user.username }
  end

  let(:user_token) do
    FactoryGirl.create(:carto_user_token, user_table_id: @table.id)
  end

  describe "#index" do
    it "returns user tokens" do
      user_token # Create the user token
      get_json api_v1_tables_user_tokens_list_url(params) do |response|
        expect(response.status).to eq(200)
        expect(response.body.to_json).to eq([user_token].to_json)
      end
    end
  end

  describe "#show" do
    it "returns a user_token" do
      params.merge!(id: user_token.id)
      get_json api_v1_tables_user_tokens_show_url(params) do |response|
        expect(response.status).to eq(200)
        expect(response.body.to_json).to eq(user_token.to_json)
      end
    end
  end

  describe "#create" do
    it "create a read user token by default" do
      post_json api_v1_tables_user_tokens_create_url(params) do |response|
        expect(response.status).to eq(200)
        expect(response.body[:user_token][:writable]).to be false
      end
    end

    it "create a read user token explicitly" do
      params.merge!(writable: false)
      post_json api_v1_tables_user_tokens_create_url(params) do |response|
        expect(response.status).to eq(200)
        expect(response.body[:user_token][:writable]).to be false
      end

    end

    it "create a write user token explicitly" do
      params.merge!(writable: true)
      post_json api_v1_tables_user_tokens_create_url(params) do |response|
        expect(response.status).to eq(200)
        expect(response.body[:user_token][:writable]).to be true
      end
    end
  end

  describe "#destroy" do
    it "destroy a user token" do
      user_token # Create the user token
      expect {
        params.merge!(id: user_token.id)
        delete_json api_v1_tables_user_tokens_show_url(params) do |response|
          expect(response.status).to eq(200)
        end
      }.to change(Carto::UserToken, :count).by(-1)
    end
  end

end
