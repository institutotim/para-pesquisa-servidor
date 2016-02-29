class FieldsController < ApplicationController
  load_and_authorize_resource

  def index
    expose Section.find(params[:section_id]).fields
  end

  def show
    expose Field.find(params[:id])
  end

  def create
    field = Section.find(params[:section_id]).fields.create! field_params
    json_set_status :created
    expose field_id: field.id
  end

  def update
    field = Field.find(params[:id])
    field = field.becomes!(Kernel.const_get(params[:type])) if params[:type]

    field_parameters = field_params
    field.options    = field_parameters.extract!(:options) if field_parameters[:options].present?
    field.update! field_params
    json_set_status :no_content
  end

  def destroy
    Field.find(params[:id]).destroy
    json_set_status :no_content
  end

  def update_order
    params[:order].each_with_index do |id, index|
      Field.find(id).update order: index + 1
    end

    json_set_status :no_content
  end

  private
    def field_params
      params.permit :label, :description, :type, :layout, :read_only, :identifier, options: [:label, :value],
                    validations: [:required, :range], actions: [when: [], enable: [], disable: [], disable_sections: []]
    end
end
