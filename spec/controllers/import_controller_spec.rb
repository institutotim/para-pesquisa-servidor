require 'spec_helper'
require 'csv'

describe ImportController do
  let(:default_params) { {use_route: :import} }
  let!(:form) { Fabricate :form }
  let!(:user_1) { Fabricate :user, username: 'Entrevistador - 1' }
  let!(:user_2) { Fabricate :user, username: 'Entrevistador - 2' }

  def parse_sample
    post :parse, default_params.merge(file: fixture_file_upload('correct_sample.csv', 'text/csv'))
    assert_response :success

    json_response['job_id']
  end

  def import_sample(job_id)
    post :import, default_params.merge(substitution: 'Substituição', grouping: 'Atribuição de Jovem', identifier: 'Endereço', job_id: job_id, form_id: form.id)
    assert_response :success
  end

  def parse_and_import_sample
    job_id = parse_sample
    result = import_sample(job_id)
    [job_id, result]
  end

  before :each do
    @user = log_in :api
  end

  context 'successful requests' do
    it 'should parse the headers correctly' do
      post :parse, default_params.merge(file: fixture_file_upload('correct_sample.csv', 'text/csv'))
      assert_response :success

      correct_headers = File.open(Rails.root.join('spec/fixtures/correct_sample.csv'), 'rb').readline().force_encoding('utf-8').parse_csv :col_sep => ';'

      json_response['header_columns'].each do |header|
        expect(correct_headers).to include(header)
      end

      expect(json_response['job_id']).not_to be_empty
    end

    it 'should create extra fields and the identifier correctly' do
      parse_and_import_sample
      correct_headers = File.open(Rails.root.join('spec/fixtures/correct_sample.csv'), 'rb').readline().force_encoding('utf-8').parse_csv :col_sep => ';'

      correct_headers.delete('Substituição').delete('Atribuição de Jovem').delete('Endereço')
      read_only_field_labels = form.fields.where(:read_only => true).map { |f| f.label }
      correct_headers.compact.each { |header| expect(header.force_encoding('utf-8')).to be_in(read_only_field_labels) }
      expect(form.fields.where(:identifier => true).first.label).to eq('Endereço')
    end

    it 'should create submissions with the status new and create a log entry' do
      parse_and_import_sample

      expect(Submission.first.status).to eq('new')
      expect(Submission.first.log.first.action).to eq('created')
      expect(Submission.first.log.first.user_id).to eq(@user.id)
    end

    it 'should import submissions without substitution and identifier' do
      submissions = Submission.all
      job_id = parse_sample
      post :import, default_params.merge(job_id: job_id, form_id: form.id, grouping: 'Atribuição de Jovem')
      assert_response :success

      expect(json_response['successful_imports']['1'][0]['id']).to eq(submissions.first.id)
      expect(json_response['successful_imports']['2'][0]['id']).to eq(submissions.second.id)
      expect(json_response['successful_imports']['3'][0]['id']).to eq(submissions.third.id)
    end

    it 'should import submissions with substitutions' do
      submissions = Submission.all
      job_id = parse_sample

      post :import, default_params.merge(job_id: job_id, form_id: form.id, substitution: 'Substituição', grouping: 'Atribuição de Jovem')
      assert_response :success

      expect(json_response['successful_imports']['1'][0]['id']).to eq(submissions.first.id)
      expect(json_response['successful_imports']['1'][1]['id']).to eq(submissions.third.id)
      expect(json_response['successful_imports']['2'][0]['id']).to eq(submissions.second.id)
    end

    it 'should import submissions with grouping' do
      job_id = parse_sample

      post :import, default_params.merge(job_id: job_id, form_id: form.id, grouping: 'Atribuição de Jovem')
      assert_response :success

      expect(json_response['successful_imports']['1'][0]['user_id']).to eq(user_1.id)
      expect(json_response['successful_imports']['2'][0]['user_id']).to eq(user_2.id)
      expect(json_response['successful_imports']['3'][0]['user_id']).to eq(user_1.id)
      expect(json_response['failed_imports']['4'][0]['error']).to eq('user_not_found')
      expect(json_response['failed_imports']['4'][0]['line']).to eq(5)
    end

    it 'should import submissions when substitution, grouping and identifier are present' do
      job_id = parse_sample

      post :import, default_params.merge(substitution: 'Substituição', grouping: 'Atribuição de Jovem', identifier: 'Código de Logradouro', job_id: job_id, form_id: form.id)
      assert_response :success

      expect(json_response['successful_imports']['1'][0]['user_id']).to eq(user_1.id)
      expect(json_response['successful_imports']['1'][1]['user_id']).to eq(user_1.id)
      expect(json_response['successful_imports']['2'][0]['user_id']).to eq(user_2.id)
      expect(json_response['failed_imports']['4 IM NOT A NUMBER'][0]['error']).to eq('user_not_found')
      expect(json_response['failed_imports']['4 IM NOT A NUMBER'][0]['line']).to eq(5)
    end
  end
end
