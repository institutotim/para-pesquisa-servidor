require 'spec_helper'

describe SubmissionsController do
  default_version 1
  let(:default_params) { {use_route: :submissions} }

  context 'successful requests' do

    before do
      @user = log_in :api
    end

    it 'should display the list without any filter' do
      get :index, default_params
      expect(response).to be_paginated_resource
      expect(response).to have_exposed Submission.all
    end

    it 'should display only submissions created_from a date' do
      invalid_submission = Fabricate :submission, created_at: DateTime.now - 50.seconds
      valid_submission   = Fabricate :submission

      get :index, default_params.merge(created_from: DateTime.now)
      expect(json_response[0]['id']).to eq(valid_submission.id)
      expect(json_response.length).to eq(1)
    end

    it 'should reset a submission' do
      submission = Fabricate :submission
      submission.answers = {}
      post :reset, default_params.merge(:submission_id => submission.id)
    end
  end

  describe 'POST submission' do
    before { @user = log_in(:api) }

    context 'failure'

    context 'successful' do
      context 'when one field has an action to disable a page' do
        context 'when form need to be moderate' do
          let(:moderator) { Fabricate :mod }
          let!(:form)     { Fabricate :form }
          let!(:section1) { Fabricate :section, name: 'Page 1', form: form }
          let!(:section2) { Fabricate :section, name: 'Page 2', form: form }
          let(:actions1)  { [{when: ['Option2'], disable_section: [section2.id]}] }
          let(:options1)  { [{label: 'Option1', value: 'Option1'}, {label: 'Option2', value: 'Option2'}] }
          let!(:field1_1) { Field.create section: section1, label: 'Field 1', type: 'SelectField', layout: 'small', actions: actions1, options: options1 }
          let!(:field2_1) { Field.create section: section2, label: 'Field 2', type: 'TextField', layout: 'small' }
          let!(:field2_2) { Field.create section: section2, label: 'Field 3', type: 'TextField', layout: 'small', validations: {required: true} }

          before do
            Assignment.create(form_id: form.id, user_id: @user.id, mod_id: moderator.id, quota: 10)
            post :create, default_params.merge(form_id: form.id, answers: [[field1_1.id, ['Option2']]])
          end

          context 'Submission' do
            subject { Submission.last }

            its(:status) { should eql 'waiting_approval' }

            context 'Section1' do
              it 'Field1 Data be present' do
                expect(subject.answers[field1_1.id.to_s]).to be_present
              end
            end

            context 'Section2' do
              it 'Field2 Data be blank' do
                expect(subject.answers[field2_1.id.to_s]).to be_blank
              end

              it 'Field3 Data be blank' do
                expect(subject.answers[field2_2.id.to_s]).to be_blank
              end
            end
          end
        end
      end
    end
  end
end
