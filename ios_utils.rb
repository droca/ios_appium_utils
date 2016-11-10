module IosUtils

  class WebviewUtils
    require 'logger'
    
    class << self
    
    #
    # Create logger with the default log level of Debug
    #
    def self.create_logger
      $logger = Logger.new(STDOUT)
      $logger.level = Logger::DEBUG
    end
    
    #
    # Check is element is present or not
    # how: method used to find the element, :id, :xpath, etc
    # what: locator, format depending on the find method 'id_value', "//div[@name='...']"
    #
    def is_element_present(how, what)
      $driver.manage.timeouts.implicit_wait=2
      result = $driver.find_elements(how, what).size > 0
      $logger.debug("size: #{$driver.find_elements(how, what).size}")

      if result
        result = $driver.find_element(how, what).displayed?
        $logger.debug("displayed?: #{result}")
      end
      $driver.manage.timeouts.implicit_wait = 30
      return result
    end

    #
    # Scroll down the provided amount of pixels
    #
    def scroll_down(amount)
      $driver.execute_script("window.scrollBy(0,#{amount});")
    end

    #
    # Scroll down until the bottom of the document is reached
    #
    def scroll_down_until_bottom(amount)
      scroll_height = $driver.execute_script("return document.body.scrollHeight;")
      scroll_top = $driver.execute_script("return document.body.scrollTop;")
      window_height = $driver.execute_script("return $(window).height();")

      yet_to_scroll = scroll_height.to_i - (scroll_top.to_i + window_height.to_i)

      if yet_to_scroll > amount
        scroll_down(amount)
      end
    end

    #
    # Returns true when the user can still sroll down the provided amount without reaching the bottom of the document
    #
    def can_scroll(amount)
      scroll_height = $driver.execute_script("return document.body.scrollHeight;")
      scroll_top = $driver.execute_script("return document.body.scrollTop;")
      window_height = $driver.execute_script("return $(window).height();")

      yet_to_scroll = scroll_height.to_i - (scroll_top.to_i + window_height.to_i)

      if yet_to_scroll > amount
        return true
      else
        return false
      end
    end

    #
    # Scroll down until the element is found
    # @params:
    # amount: number of pixels to scroll down
    # how: method used to find the element, :id, :xpath, etc
    # what: locator, format depending on the find method 'id_value', "//div[@name='...']"
    # returns the element
    def scroll_down_until_found(amount, how, what)

      while self.can_scroll(amount) && !self.is_element_present(how,what)
        self.scroll_down(amount)
      end

      #TODO maybe not raise an standard error but just make the scenario fail, but continue with the rest of scenarios
      if !is_element_present(how,what)
        raise StandardError.new('Element not found')
      end
      return $driver.find_element(how, what)

   end
end
