module Capybara::Selenium::Workarounds
  module Chrome
    def accept_modal_with_headless_chrome(_type, options={})
      if headless?
        raise ArgumentError, "Block that triggers the system modal is missing" unless block_given?
        insert_modal_handlers(true, options[:with], options[:text])
        yield
        find_headless_modal(options)
      else
        accept_modal_without_headless_chrome(_type, options)
      end
    end

    def dismiss_modal_with_headless_chrome(_type, options={})
      if headless?
        raise ArgumentError, "Block that triggers the system modal is missing" unless block_given?
        insert_modal_handlers(false, options[:with], options[:text])
        yield
        find_headless_modal(options)
      else
        dismiss_modal_without_headless_chrome(_type, options)
      end
    end

    def self.extended(base)
      base.singleton_class.instance_eval do
        ['accept', 'dismiss'].each do |action|
          alias_method "#{action}_modal_without_headless_chrome", "#{action}_modal"
          alias_method "#{action}_modal", "#{action}_modal_with_headless_chrome"
        end
      end
    end

    private

      def insert_modal_handlers(accept, response_text, expected_text=nil)
        script = <<-JS
          if (typeof window.capybara  === 'undefined') {
            window.capybara = {
              modal_handlers: [],
              current_modal_status: function() {
                return [this.modal_handlers[0].called, this.modal_handlers[0].modal_text];
              },
              add_handler: function(handler) {
                this.modal_handlers.unshift(handler);
              },
              remove_handler: function(handler) {
                window.alert = handler.alert;
                window.confirm = handler.confirm;
                window.prompt = handler.prompt;
              },
              handler_called: function(handler, str) {
                handler.called = true;
                handler.modal_text = str;
                this.remove_handler(handler);
              }
            };
          };

          var modal_handler = {
            prompt: window.prompt,
            confirm: window.confirm,
            alert: window.alert,
            called: false
          }
          window.capybara.add_handler(modal_handler);

          window.alert = window.confirm = function(str = "") {
            window.capybara.handler_called(modal_handler, str.toString());
            return #{accept ? 'true' : 'false'};
          }
          window.prompt = function(str = "", default_text = "") {
            window.capybara.handler_called(modal_handler, str.toString());
            return #{accept ? (response_text.nil? ? "default_text" : "'#{response_text}'") : 'null'};
          }
        JS
        execute_script script
      end

      def find_headless_modal(options={})
        # Selenium has its own built in wait (2 seconds)for a modal to show up, so this wait is really the minimum time
        # Actual wait time may be longer than specified
        wait = Selenium::WebDriver::Wait.new(
          timeout: options.fetch(:wait, session_options.default_max_wait_time) || 0 ,
          ignore: Selenium::WebDriver::Error::NoAlertPresentError)
        begin
          wait.until do
            called, alert_text = evaluate_script('window.capybara && window.capybara.current_modal_status()')
            if called
              execute_script('window.capybara && window.capybara.modal_handlers.shift()')
              regexp = options[:text].is_a?(Regexp) ? options[:text] : Regexp.escape(options[:text].to_s)
              if alert_text.match(regexp)
                alert_text
              else
                raise Capybara::ModalNotFound.new("Unable to find modal dialog#{" with #{options[:text]}" if options[:text]}")
              end
            elsif called.nil?
              # page changed so modal_handler data has gone away
              warn "Can't verify modal text when page change occurs - ignoring" if options[:text]
              ""
            else
              nil
            end
          end
        rescue Selenium::WebDriver::Error::TimeOutError
          raise Capybara::ModalNotFound.new("Unable to find modal dialog#{" with #{options[:text]}" if options[:text]}")
        end
      end

  end
end