require 'spec_helper'

describe UsersController do
  default_version 1

  let(:default_params) { {use_route: :users} }

  describe 'successful requests' do
    before :each do
      @user = log_in(:api)
    end

    it 'should display a list of users' do
      get :index, default_params
      assert_response :success
      expect(json_response[0]['id']).to eql(@user.id) # log_in creates a user
    end

    it 'should create a user' do
      post :create, default_params.merge(username: 'unique_username', password: 'secret', role: 'api')
      assert_response :created
      expect(response).to have_exposed :user_id => User.find_by_username('unique_username').id
    end

    it 'should update a user' do
      user_details = {id: @user.id, name: 'Fulano da Silva', email: 'fulano@silva.com', avatar: fixture_file_upload('logo.jpg', 'image/jpeg')}
      put :update, default_params.merge(user_details)
      assert_response :no_content

      get :show, default_params.merge(:id => @user.id)
      user_details.extract! :avatar
      user_details['avatar'] = '/uploads/logo.jpg'
      user_details.each do |attribute, value|
        expect(json_response[attribute.to_s]).to eq(value)
      end
    end
  end
end