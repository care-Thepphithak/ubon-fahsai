module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || determine_redirect_url_for(Current.session.user)
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def determine_redirect_url_for(user)
      user.is_admin? ? admin_dashboard_index_url : root_url
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end

    def require_admin
      if !authenticated? || !Current.session&.user&.is_admin?
        redirect_to root_url
      end
    end

    def require_client
      if !authenticated? || Current.session&.user&.is_admin?
        redirect_to admin_dashboard_index_url
      end
    end

    def restrict_by_user_role
      return unless authenticated?
      return if request.path.start_with?("/minio/")

      if Current.session&.user&.is_admin? && !request.path.start_with?("/admin/")
        redirect_to admin_dashboard_index_url
      elsif !Current.session&.user&.is_admin? && request.path.start_with?("/admin/")
        redirect_to root_url
      end
    end
end
