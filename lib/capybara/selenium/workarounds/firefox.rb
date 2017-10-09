module Capybara::Selenium::Workarounds
  module Firefox
    def browser_with_firefox
      unless @browser
        options[:desired_capabilities] ||= {}
        options[:desired_capabilities].merge!({ unexpectedAlertBehaviour: "ignore" })
      end

      browser_without_firefox
    end

    def self.extended(base)
      base.singleton_class.instance_eval do
        alias_method "browser_without_firefox", "browser"
        alias_method "browser", "browser_with_firefox"
      end
    end
  end
end