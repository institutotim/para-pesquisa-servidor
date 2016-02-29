require 'spec_helper'

describe AuthController do
  context 'successful requests' do
    it 'should authenticate with the right credentials' do
      user = Fabricate :user
      post :login, {username: user.username, password: user.password, use_route: :auth}, 'CONTENT_TYPE' => 'application/json'
      assert_response :success
      json_response['user_id'].should == user.id
      expect(json_response['session_id']).not_to be_empty
    end

    it 'should end the session' do
      user = Fabricate :user
      session[:user_id] = user.id
      post :logout, use_route: :auth
      assert_response :no_content
      session[:user_id].should_not be_present
    end
  end

  context 'failed requests' do
    it 'should not allow authentication with incorrect credentials' do
      post :login, {username: 'random', password: 'pass', use_route: :auth}, 'CONTENT_TYPE' => 'application/json'
      assert_response :bad_request
    end
  end
end