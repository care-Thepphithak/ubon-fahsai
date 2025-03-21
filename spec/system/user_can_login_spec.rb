require 'rails_helper'
require_relative '../helpers/shared_context/admin_can_login_spec'

RSpec.describe "User Login", type: :system do
  include_context 'admin_can_login'
end
