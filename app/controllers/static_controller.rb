class StaticController < ApplicationController
  def show_config
    authorize! :read, :application_config
    config = ::Configuration.new
    expose config.all
  end

  def save_config
    authorize! :write, :application_config

    config = ::Configuration.new

    if application_params.include? :header
      if application_params[:header].nil?
        config.header_url = nil
      else
        uploader = ImageUploader.new
        uploader.store! params[:header]
        config.header_url = uploader.url
      end
    end

    application_params.except(:header).each do |param, value|
      config.send("#{param}=", value)
    end

    config.update
    head :no_content
  end

  private
  def application_params
    params.permit :title_line_2, :title_line_1, :header, :language, :timezone
  end
end
