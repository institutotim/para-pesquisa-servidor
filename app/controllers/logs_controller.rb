class LogsController < ApplicationController
  load_and_authorize_resource

  def index
    listing = Log.joins(:user).order(id: :desc)
    listing = datetime_filters(listing, nil, 'logs')
    listing = listing.where(user_id: params[:user_id]) if params[:user_id].present?

    expose listing.paginate(page: params[:page]), each_serializer: FullLogSerializer
  end
end
