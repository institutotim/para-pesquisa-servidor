class SectionsController < ApplicationController
  load_and_authorize_resource

  def index
    expose Form.find(params[:form_id]).sections
  end

  def show
    expose Section.find(params[:id])
  end

  def create
    section = Form.find(params[:form_id]).sections.create! section_params
    head :created
    expose section_id: section.id
  end

  def update
    Section.find(params[:id]).update! section_params
    head :no_content
  end

  def destroy
    Section.find(params[:id]).destroy
    head :no_content
  end

  def update_order
    params[:order].each_with_index do |id, index|
      Section.find(id).update order: index + 1
    end

    head :no_content
  end

  private
  def section_params
    params.permit :name, :order
  end
end
