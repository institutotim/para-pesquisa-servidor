class FormsController < ApplicationController
  load_and_authorize_resource

  def index
    expose Form.paginate(page: params[:page]), only: [:id, :name, :subtitle, :created_at, :updated_at]
  end

  def show
    expose Form.find(params[:id])
  end

  def create
    Form.transaction do
      form = Form.create! forms_param
      head :created
      expose form_id: form.id
    end
  end

  def update
    Form.find(params[:id]).update! forms_param
    head :no_content
  end

  def destroy
    Form.find(params[:id]).destroy
    head :no_content
  end

  def copy
    other  = Form.find(params[:id])
    copied = other.dup(include: { sections:  { fields: :choices } })
    copied.name = copied.name + I18n.t(:sub_name_to_copy)
    copied.save
    expose form_id: copied.id
  end

  def update_order
    params[:order].each_with_index do |id, index|
      Form.find(id).update order: index + 1
    end

    head :no_content
  end

  private
  def forms_param
    params.permit :name, :subtitle, :pub_start, :pub_end, :allow_transfer, :max_reschedules, :requires_approval
  end
end
