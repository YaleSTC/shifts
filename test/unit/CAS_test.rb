module Kernel
  def singleton_class
    class << self; self; end
  end
end

module CasTestHelper
  def assert_redirected_to_login
    assert_response :redirect
    assert_match(/#{CASClient::Frameworks::Rails::Filter.config[:login_url]}/,redirect_to_url)
  end

  def stub_cas_logged_in(user)
    unstub_cas
    CASClient::Frameworks::Rails::Filter.singleton_class.send :define_method, :filter do |controller|
      controller.session[:cas_user] = user.cas_username
      controller.session[:user] = user.id
      true
    end
  end

  def stub_cas_logged_out
    unstub_cas
    CASClient::Frameworks::Rails::Filter.singleton_class.send :define_method, :filter do |controller|
      controller.send(:redirect_to, 'access/denied')
      controller.send(:reset_session)
      false
    end
  end

  def unstub_cas
    CASClient::Frameworks::Rails::Filter.singleton_class.class_eval do
      if self.respond_to?(:original_filter)
        alias :filter :original_filter
        undef :original_filter
      end
    end
    CASClient::Frameworks::Rails::Filter.singleton_class.class_eval do
      alias :original_filter :filter
    end
  end
end

