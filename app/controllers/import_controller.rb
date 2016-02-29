require 'csv'

class ImportCSVException < Exception;
end

class ImportController < ApplicationController
  def parse
    authorize! :import_csv, Form

    return head(:bad_param) if params[:file].blank?

    csv_file  = params[:file].read
    separator = params[:separator] || get_separator(csv_file)

    raise I18n.t(:undefined_separator) if separator.nil?

    begin
      encoding = params[:encoding] || 'UTF-8'
      csv_file.force_encoding(encoding).encode('UTF-8')
    rescue Encoding::UndefinedConversionError
      raise I18n.t(:file_isnt_utf8_encode)
    end

    begin
      parsed_csv = CSV.parse(csv_file, col_sep: separator)
    rescue CSV::MalformedCSVError => e
      raise I18n.t(:csv_with_bad_format, message: e.message)
    end

    job_id = SecureRandom.hex
    Rails.cache.write(job_id, parsed_csv)

    expose header_columns: parsed_csv[0].compact, job_id: job_id
  end

  # TODO: Refactor this
  def import
    authorize! :import_csv, Form

    parsed_csv = Rails.cache.read(params[:job_id])
    form       = Form.find(params[:form_id])

    raise "Job_id #{I18n.t(:invalid)}" if parsed_csv.nil?

    Rails.cache.delete(params[:job_id])

    raise I18n.t(:form_not_found) if form.nil?

    raise I18n.t(:this_form_has_already_started_with_manual_searches) if form.allow_new_submissions == true

    form.update(allow_new_submissions: false) if form.allow_new_submissions.nil?

    headers = parsed_csv.delete_at(0)

    import_params.values.each { |column| raise I18n.t(:column_not_found, column: column) unless headers.include?(column) }

    form.sections.create!(name: I18n.t(:page_1)) if form.sections.count < 1

    raise I18n.t(:user_attribution_is_required) if import_params[:grouping].nil?

    substitution_index = headers.index(import_params[:substitution]) unless import_params[:substitution].nil?
    username_index     = headers.index(import_params[:grouping])
    identifier_index   = headers.index(import_params[:identifier]) unless import_params[:identifier].nil?

    unless identifier_index.nil?
      identifier_field = form.fields.where(identifier: true, read_only: true, label: headers[identifier_index]).first ||
                         TextField.create!(label: headers[identifier_index], read_only: true, identifier: true, section: form.sections.first)
    end

    [substitution_index, username_index].compact.each { |meta_field_index| headers.delete_at(meta_field_index) }

    fields = create_extra_fields form, headers
    result = {successful_imports: {}, failed_imports: {}}
    main_submissions = {}

    parsed_csv.each_with_index do |line, line_number|
      if substitution_index.nil?
        group_index = (line_number + 1).to_s
      else
        group_index = line[substitution_index]
      end

      submission = form.submissions.new
      submission.status = 'new'

      fields.each_with_index do |field, index|
        value = line[index].to_s

        unless identifier_field.nil?
          value = value.titleize if identifier_field.id == field.id
        end

        submission.answers[field.id] = value
      end

      user = User.find_by_username(line[username_index])

      if user.nil?
        result[:failed_imports][group_index] ||= []
        result[:failed_imports][group_index].push error: 'user_not_found', line: line_number + 2 # Cabeçalho + index
        next
      end

      submission.user  = user
      assignment       = Assignment.find_or_create_by(form_id: form.id, user_id: user.id)
      assignment.update!(quota: assignment.submissions.count + 1)
      submission.update!(assignment: assignment)

      submission.log.create! action: 'created', date: DateTime.now, user: current_user

      if result[:successful_imports][group_index].nil?
        main_submissions[group_index] = submission
        result[:successful_imports][group_index] = []
      else
        unless username_index.nil?
          raise I18n.t(:try_to_import_overwrite_to_a_diferent_user) if main_submissions[group_index].user.id != user.id
        end

        main_submissions[group_index].alternatives << submission
      end

      single_import = {id: submission.id}
      single_import[:user_id] = submission.user.id unless username_index.nil?
      result[:successful_imports][group_index].push single_import
    end

    expose result
  end

  private
  def create_extra_fields(form, fields)
    fields.compact.map do |label|
      form.fields.where(read_only: true, label: label).first ||
      TextField.create!(label: label, read_only: true, section: form.sections.first)
    end
  end

  def import_params
    params.permit :substitution, :grouping, :identifier
  end

  def get_separator(sample)
    comma_count = sample.count(',')
    semicolon_count = sample.count(';')

    return nil if comma_count == 0 and semicolon_count == 0

    semicolon_count > comma_count ? ';' : ','
  end
end
