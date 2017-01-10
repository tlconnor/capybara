# frozen_string_literal: true
require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'

Capybara.register_driver :selenium_safari do |app|
  Capybara::Selenium::Driver.new(app, :browser => :safari)
end

module TestSessions
  Safari = Capybara::Session.new(:selenium_safari, TestApp)
end

skipped_tests = [:response_headers, :status_code, :trigger]
skipped_tests << :windows if ENV['TRAVIS'] && !ENV['WINDOW_TEST']

Capybara::SpecHelper.run_specs TestSessions::Safari, "selenium_safari", capybara_skip: skipped_tests

# RSpec.describe "Capybara::Session with Safari" do
#   include_examples  "Capybara::Session", TestSessions::Safari, :selenium_safari
#
#   context "storage" do
#     describe "#reset!" do
#       it "does not clear either storage by default" do
#         @session = TestSessions::Chrome
#         @session.visit('/with_js')
#         @session.find(:css, '#set-storage').click
#         @session.reset!
#         @session.visit('/with_js')
#         expect(@session.driver.browser.local_storage.keys).not_to be_empty
#         expect(@session.driver.browser.session_storage.keys).not_to be_empty
#       end
#
#       it "clears storage when set" do
#         @session = Capybara::Session.new(:selenium_chrome_clear_storage, TestApp)
#         @session.visit('/with_js')
#         @session.find(:css, '#set-storage').click
#         @session.reset!
#         @session.visit('/with_js')
#         expect(@session.driver.browser.local_storage.keys).to be_empty
#         expect(@session.driver.browser.session_storage.keys).to be_empty
#       end
#     end
#   end
# end
