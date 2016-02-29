require 'raven'

class ApplicationController < RocketPants::Base
  include CanCan::ControllerAdditions
  include ActionController::Rendering
  check_authorization except: [:options, :admin]
  jsonp

  before_filter :set_api_version
  before_filter :set_no_cache_header
  before_filter :set_locale_and_timezone
  after_filter  :ensure_valid_output

  rescue_from Exception do |exception|
    Raven.capture_exception exception

    if exception.class == CanCan::AccessDenied
      json_set_status :forbidden
      render_json error: 'authorization_error', error_description: I18n.t(:access_denied)
    else
      json_set_status :unprocessable_entity
      render_error exception
    end
  end unless Rails.env.development?

  def current_user
    User.find_by_id(session[:user_id])
  end

  # Todo: rename for clarity
  def options
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, PUT, DELETE'
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, content-type, origin, X-Session-ID'
    response.headers['Access-Control-Max-Age'] = '1728000'
    head :no_content
  end

  def json_set_status(status)
    self.response.status = status
    self.response.content_type = 'application/json'
    self.response.charset = 'utf-8'
  end

  def get_diff(original, other)
    modified_attributes = {}

    original_keys = original.keys

    # Retrieve changes present in the original object in relation to the other
    # any key present in the original but not in the other will be added as a nil key
    original_keys.each { |key| modified_attributes[key] = other[key] if original[key] != other[key] }

    # Retrieve attributes that are only present in the other object but not in the original one
    new_keys = other.keys - original_keys

    new_keys.each { |key| modified_attributes[key] = other[key] }

    modified_attributes
  end

  def create_serialized_stash(objects)
    stash = {}
    objects.each { |object| stash[object.id] = object.active_model_serializer.new(object).as_json(root: false) }
    stash
  end

  def get_changes_for_user(key, serialized_objects, timestamps=nil)
    change_list = []

    keys_in_user_stash = []

    session[key] ||= {}

    session[key].each do |id, stashed_object|
      unless serialized_objects.include?(id)
        change_list.append({:id => stashed_object[:id], '$keep' => false})
        next
      end

      current_object = serialized_objects[id]

      stashed_object = {} if not timestamps.nil? and current_object.include?(:updated_at) and (timestamps[id].nil? or current_object[:updated_at].to_i != timestamps[id])

      diff = get_diff(stashed_object, current_object)

      keys_in_user_stash.append(id)

      unless diff.blank?
        diff['$keep'] = true
        diff['id'] = id
        change_list.append(diff)
      end
    end

    new_object_keys = serialized_objects.keys - keys_in_user_stash

    new_object_keys.each do |new_object_key|
      change_list.append(serialized_objects[new_object_key])
    end

    change_list
  end

  def expose_stashed(key, objects, options={})
    if request.headers.include?('HTTP_IF_NONE_MATCH') and request.headers['HTTP_IF_NONE_MATCH'] == session.id
      timestamps = ActiveSupport::JSON.decode(request.headers['HTTP_X_TIMESTAMPS']) if request.headers.include?('HTTP_X_TIMESTAMPS')
      timestamps_hash = Hash[timestamps.map { |entry| [entry['id'], entry['timestamp']] }] unless timestamps.nil?
      serialized_objects = create_serialized_stash(objects)
      change_list = get_changes_for_user(key, serialized_objects, timestamps_hash)
      session[key] = serialized_objects
      expose change_list, options
    else
      expose objects
    end
  end

  # Todo: find a better way to do this
  def datetime_filters(listing, filters = nil, table_prefix = nil)
    table_prefix = table_prefix.nil? ? '' : table_prefix + '.'

    format_field = lambda { |field_needing_substitution| table_prefix + field_needing_substitution.to_s.sub(/(from|to)/i, 'at') }

    (filters || [:created_to, :updated_to, :created_from, :updated_from]).each do |unformatted_field|
      operator = unformatted_field.to_s.index('from') ? '>' : '<'
      listing = listing.where(format_field.call(unformatted_field) + ' ' + operator + ' ?', DateTime.parse(params[unformatted_field])) unless params[unformatted_field].nil?
    end

    listing
  end

  private
    def set_api_version
      $api_version = params[:version].to_i
    end

    def set_no_cache_header
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma']        = 'no-cache'
      response.headers['Expires']       = 'Fri, 01 Jan 1990 00:00:00 GMT'
    end

    def ensure_valid_output
      if response.content_type == 'application/json' && response.status != 204 && (!response.body || response.body.to_s.strip.blank?)
        head :unprocessable_entity if $api_version == 2 and response.status == 400
        response.body = env['PATH_INFO'] && env['PATH_INFO'].last == 's' ? '[]' : '{}'
      end
    end

    def set_locale_and_timezone
      config = ::Configuration.new
      I18n.locale = config.language if config.language?
      Time.zone   = config.timezone if config.timezone?
    end
end
