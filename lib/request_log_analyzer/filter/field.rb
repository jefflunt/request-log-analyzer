module RequestLogAnalyzer::Filter
  
  # Filter to select or reject a specific field
  # Options
  # * <tt>:mode</tt> :reject or :accept.
  # * <tt>:field</tt> Specific field to accept or reject.
  # * <tt>:value</tt> Value that the field should match to be accepted or rejected.
  class Field < Base
   
    attr_reader :field, :value, :mode
   
    # Setup mode, field and value.
    def prepare
      @mode = (@options[:mode] || :accept).to_sym
      @field = @options[:field].to_sym
      
      # Convert the timestamp to the correct formats for quick timestamp comparisons
      if @options[:value].kind_of?(String) && @options[:value][0, 1] == '/' && @options[:value][-1, 1] == '/'
        @value = Regexp.new(@options[:value][1..-2])
      else
        @value = @options[:value] # TODO: convert value?
      end
    end
    
    # Keep request if @mode == :select and request has the field and value.
    # Drop request if @mode == :reject and request has the field and value.
    # Returns nil otherwise.
    # <tt>request</tt> Request Object
    def filter(request)
      return nil unless request
      
      found_field = request.every(@field).any? { |value| @value === value.to_s }
      
      return nil if !found_field && @mode == :select
      return nil if found_field && @mode == :reject
      
      return request
    end 
  end
  
end