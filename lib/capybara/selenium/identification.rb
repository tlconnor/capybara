# @api private
module Capybara::Selenium::Identification
  def marionette?
    firefox? && browser && w3c?
  end

  def firefox?
    browser_name == "firefox"
  end

  def chrome?
    browser_name == "chrome"
  end

  def headless?
    if chrome?
      caps = @processed_options[:desired_capabilities]
      chrome_options = caps[:chrome_options] || caps[:chromeOptions] || {}
      args = chrome_options['args'] || chrome_options[:args] || []
      return args.include?("--headless") || args.include?("headless")
    end
    return false
  end

  def headless_chrome?
    chrome? && headless?
  end

  def w3c?
    ((defined?(Selenium::WebDriver::Remote::W3CCapabilities) && @browser.capabilities.is_a?(Selenium::WebDriver::Remote::W3CCapabilities)) ||
     (defined?(Selenium::WebDriver::Remote::W3C::Capabilities) && @browser.capabilities.is_a?(Selenium::WebDriver::Remote::W3C::Capabilities)))
  end



  private

    def browser_name
      options[:browser].to_s
    end

end