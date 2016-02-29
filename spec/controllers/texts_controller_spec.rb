require 'spec_helper'

describe TextsController do
  let(:default_params) { {use_route: :texts, version: 1} }
  let(:text_template) { {title: 'Some title', content: 'Some content', subtitle: 'Some subtitle'} }

  describe 'successful requests' do
    before do
      @user = log_in(:api)
    end

    it 'should return the texts in the database' do
      text = Text.create! text_template

      get :index, default_params
      expect(json_response[0]['title']).to eql(text[:title])
      expect(json_response[0]['content']).to eql(text[:content])
      expect(json_response[0]['subtitle']).to eql(text[:subtitle])
    end

    it 'should create a new text and return its ID' do
      post :create, default_params.merge(text_template)

      assert_response :created
      expect(json_response['text_id']).to be_kind_of Integer
    end

    it 'should update a text' do
      text = Text.create! text_template

      put :update, default_params.merge(id: text.id, subtitle: 'Changed subtitle')
      assert_response :no_content

      get :index, default_params
      expect(json_response[0]['subtitle']).to eql('Changed subtitle')
    end

    it 'should delete a text' do
      text = Text.create! text_template

      delete :destroy, default_params.merge(id: text.id)
      assert_response :no_content

      get :index, default_params
      assert_response :success
      expect(json_response.length).to eql(0)
    end

    it 'shows a single item' do
      text = Text.create! text_template

      get :show, default_params.merge(id: text.id)
      assert_response :success
      expect(json_response['title']).to eq(text.title)
      expect(json_response['subtitle']).to eq(text.subtitle)
      expect(json_response['content']).to eq(text.content)
      expect(json_response['id']).to eq(text.id)
    end
  end

  describe 'failed requests' do
    it 'should require title and content' do
      log_in(:api)
      post :create, default_params
      assert_response :unprocessable_entity
    end
  end
end