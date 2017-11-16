module LukitaService
  # Result class
  class Result
    attr_accessor :valid, :result, :error, :exception
    alias :valid? :valid

    def initialize(params)
      @valid = params[:valid?]
      @result = params[:result]
      @error = params[:error]
      @exception = params[:exception]
    end
  end
end