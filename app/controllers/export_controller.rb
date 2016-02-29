require 'csv'

class ExportController < ApplicationController
  include ActionController::DataStreaming

  skip_authorization_check only: [:progress, :exports]

  @@background_job = nil

  def exports
    job_id = Rails.cache.read('export_job_running')

    last_exports = {}
    %w(answers users forms fields submissions).each do |export|
      key    = "last_#{export}_export"
      cached = Rails.cache.read(key)
      last_exports[key] = cached.nil? ? nil : {date: cached[:date].iso8601, url: cached[:url], job_id: cached[:job_id]}
    end

    expose ({running_job_id: job_id}).merge(last_exports)
  end

  def users
    authorize! :export_csv, User

    success, job_id = background do
      users = User.active
      users = users.where(role: params[:by_role].split(',')) if params[:by_role]

      translated_role = {'mod' => I18n.t(:coordinator), 'agent' => I18n.t(:research), 'api' => I18n.t(:administrator)}
      total_users     = users.count
      processed_users = 0

      csv = CSV.generate do |csv|
        if params[:include_header] == true
          csv << ['user_id', I18n.t(:name), I18n.t(:user_name), I18n.t(:email), I18n.t(:created_at), I18n.t(:job_title)]
        end

        users.each do |user|
          csv << [user.id, user.name, user.username, user.email, user.created_at, translated_role[user.role]]

          processed_users += 1
          Rails.cache.write(job_id, total: total_users, current: processed_users, complete: false, url: nil)
        end
      end

      uploader = CsvUploader.new
      uploader.store!(CSVStringIO.new('users_' + Time.now.to_i.to_s + '.csv', csv))

      raise I18n.t(:upload_error_try_again) if uploader.file.nil?

      Rails.cache.write(job_id, url: uploader.file.url, complete: true, total: total_users, current: processed_users)
      Rails.cache.write('last_users_export', {date: Time.now, url: uploader.file.url, job_id: job_id})
    end

    raise I18n.t(:export_in_process) unless success
    Rails.cache.write(job_id, total: 0, current: 0, complete: false, url: nil)
    expose job_id: job_id
  end

  def forms
    authorize! :export_csv, Form

    success, job_id = background do
      forms           = Form.all
      total_forms     = forms.size
      processed_forms = 0

      csv = CSV.generate do |csv|
        if params[:include_header] == true
          csv << ['form_id', I18n.t(:title), I18n.t(:subtitle), I18n.t(:creation_at)]
        end

        forms.each do |form|
          csv << [form.id, form.name, form.subtitle, form.created_at]

          processed_forms += 1
          Rails.cache.write(job_id, total: total_forms, current: processed_forms, complete: false, url: nil)
        end
      end

      uploader = CsvUploader.new
      uploader.store!(CSVStringIO.new('forms_' + Time.now.to_i.to_s + '.csv', csv))

      raise I18n.t(:upload_error_try_again) if uploader.file.nil?

      Rails.cache.write(job_id, url: uploader.file.url, complete: true, total: total_forms, current: processed_forms)
      Rails.cache.write('last_forms_export', {date: Time.now, url: uploader.file.url, job_id: job_id})
    end

    raise I18n.t(:export_in_process) unless success
    Rails.cache.write(job_id, total: 0, current: 0, complete: false, url: nil)
    expose job_id: job_id
  end

  def submissions
    authorize! :export_csv, Submission

    success, job_id = background do
      submissions = Submission.with_dependencies.includes(:form)
      submissions = datetime_filters(submissions)
      submissions = submissions.where(status: params[:by_status]) if params[:by_status]
      form        = Form.includes(:fields).find(params[:form_id])

      total_submissions     = submissions.count
      processed_submissions = 0

      csv = CSV.generate do |csv|
        if params[:include_header] == true
          fixed_fields = ['submission_id', 'form_id', 'user_id']

          # If this form uses imported submissions we add the readonly fields to the header
          if form.allow_new_submissions == false
            readonly_fields = form.fields.where(read_only: true)
            readonly_fields.each { |field| fixed_fields.append(field.label) } if readonly_fields.present?
          end

          fixed_fields += [I18n.t(:creation_at), I18n.t(:filing_date), I18n.t(:approval_date)]

          csv << fixed_fields
        end

        submissions.each do |submission|
          row = [submission.id, submission.form.id, submission.user.id]

          if form.allow_new_submissions == false and not readonly_fields.nil?
            row += readonly_fields.map { |readonly_field| submission.answers[readonly_field.id] }
          end

          row += [submission.last_created_date, submission.last_started_date, submission.last_approved_date]
          csv << row

          processed_submissions += 1
          Rails.cache.write(job_id, total: total_submissions, current: processed_submissions, complete: false, url: nil)
        end
      end

      uploader = CsvUploader.new
      uploader.store!(CSVStringIO.new('submissions_' + Time.now.to_i.to_s + '.csv', csv))

      raise I18n.t(:upload_error_try_again) if uploader.file.nil?

      Rails.cache.write(job_id, url: uploader.file.url, complete: true, total: total_submissions, current: processed_submissions)
      Rails.cache.write('last_submissions_export', {date: Time.now, url: uploader.file.url, job_id: job_id})
    end

    raise I18n.t(:export_in_process) unless success
    Rails.cache.write(job_id, total: 0, current: 0, complete: false, url: nil)
    expose job_id: job_id
  end

  def fields
    authorize! :export_csv, Field

    success, job_id = background do
      fields           = Field.where(read_only: false).joins(:section)
      total_fields     = fields.size
      processed_fields = 0

      csv = CSV.generate do |csv|
        if params[:include_header] == true
          csv << ['field_id', 'form_id', I18n.t(:title), I18n.t(:type)]
        end

        fields.each do |field|
          next if field.section.nil?

          csv << [field.id, field.section.form_id, field.label, field.type]

          processed_fields += 1
          Rails.cache.write(job_id, total: total_fields, current: processed_fields, complete: false, url: nil)
        end
      end

      uploader = CsvUploader.new
      uploader.store!(CSVStringIO.new('fields_' + Time.now.to_i.to_s + '.csv', csv))

      raise I18n.t(:upload_error_try_again) if uploader.file.nil?

      Rails.cache.write(job_id, url: uploader.file.url, complete: true, total: total_fields, current: processed_fields)
      Rails.cache.write('last_fields_export', {date: Time.now, url: uploader.file.url, job_id: job_id})
    end

    raise I18n.t(:export_in_process) unless success
    Rails.cache.write(job_id, total: 0, current: 0, complete: false, url: nil)
    expose job_id: job_id
  end

  def answers
    authorize! :export_csv, Submission

    success, job_id = background do
      submissions = Submission.where(form_id: params[:form_id]).select(:id, :answers)
      submissions = datetime_filters(submissions)
      submissions = submissions.where(status: params[:by_status]) if params[:by_status]
      total_submissions     = submissions.size
      processed_submissions = 0

      csv = CSV.generate do |csv|
        if params[:include_header] == true
          csv << ['submission_id', 'field_id', I18n.t(:response), I18n.t(:order)]
        end

        submissions.each do |submission|
          submission.answers.each do |field_id, answers|
            answers = [answers] unless answers.kind_of?(Array)
            order   = 0

            answers.each do |answer|
              order += 1
              csv << [submission.id, field_id, answer, order]
            end
          end

          processed_submissions += 1
          Rails.cache.write(job_id, total: total_submissions, current: processed_submissions, complete: false, url: nil)
        end
      end

      uploader = CsvUploader.new
      uploader.store!(CSVStringIO.new('answers_' + Time.now.to_i.to_s + '.csv', csv))

      raise I18n.t(:upload_error_try_again) if uploader.file.nil?

      Rails.cache.write(job_id, url: uploader.file.url, complete: true, total: total_submissions, current: processed_submissions)
      Rails.cache.write('last_answers_export', {date: Time.now, url: uploader.file.url, job_id: job_id})
    end

    raise I18n.t(:export_in_process) unless success
    Rails.cache.write(job_id, total: 0, current: 0, complete: false, url: nil)
    expose job_id: job_id
  end

  def progress
    job_id = params[:job_id] || Rails.cache.read('export_job_running')
    raise I18n.t(:id_of_job_cant_be_blank) if job_id.nil?

    job = Rails.cache.read(job_id)
    raise I18n.t(:job_not_found) if job.nil?

    expose job
  end

  def background(&block)
    if Rails.cache.read('export_job_running').blank?
      Thread.new do
        begin
          yield
        rescue => exception
          Raven.capture_exception(exception)
        end
        ActiveRecord::Base.connection.close
        Rails.cache.delete('export_job_running')
      end

      job_id = SecureRandom.hex
      Rails.cache.write('export_job_running', job_id, expires_in: 60.minutes)
      return [true, job_id]
    end

    [false, nil]
  end
end
