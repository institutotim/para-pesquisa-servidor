APPLICATION_ROLES = :mod, :api, :agent, :guest

RSpec::Matchers.define :only_be_accessible_to do |*roles|
  match do |the_call|
    APPLICATION_ROLES.all? do |role|
      log_in(role)

      begin
        response = the_call.call
        response.status.in?([200, 201, 204, 304]) ? roles.include?(role) : false
      rescue CanCan::AccessDenied
        roles.include?(role) ? false : true
      rescue Exception => e
        false
      end
    end
  end
end