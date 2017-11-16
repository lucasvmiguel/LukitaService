module LukitaService
  # Base class
  class Base
    def self.execute; end
    def self.execute!; end

    # Run service with params
    #
    # Example:
    #   >> SumServiceExample.run(num1: 1, num2: 2)
    #   => #<LukitaService::Result:0x0000000368b110 @valid?=true, @result={:sum=>3}, @error=nil, @exception=nil>
    def self.run(params = {})
      outcome = self.execute(params)
      outcome = self.fill_outcome(outcome)

      if outcome[:valid?]
        Result.new(valid?: outcome[:valid?], result: outcome[:result], error: nil)
      else
        Result.new(valid?: outcome[:valid?], result: outcome[:result], error: outcome[:error])
      end  
    end

    # Run service with params, rescue an exception if there is exception
    #
    # Example:
    #   >> SumServiceExample.run(num1: 1, num2: 2)
    #   => #<LukitaService::Result:0x0000000368b110 @valid?=true, @result={:sum=>3}, @error=nil, @exception=nil>
    def self.run!(params = {})
      ActiveRecord::Base.transaction do
        outcome = self.execute(params)
      end
      outcome = self.fill_outcome(outcome)

      if outcome[:valid?]
        Result.new(valid?: outcome[:valid?], result: outcome[:result], error: nil, exception: nil)
      else
        Result.new(valid?: outcome[:valid?], result: outcome[:result], error: outcome[:error], exception: outcome[:exception])
      end

      rescue Exception => e 
        Result.new(valid?: outcome[:valid?], result: outcome[:result], error: e.message, exception: e)
    end

    # Run services in pipeline
    #
    # Example:
    #   >> LukitaService::Base.pipe(SimpleSumService, {a: 1, b: 2}).pipe(LogService).done
    #   => #<LukitaService::Result:0x00000002af4950 @valid=true, @result={:sum=>3}, @error=nil, @exception=nil>
    def self.pipe(service, params = {})
      if @outcome != nil && @outcome.valid?
        prev_result = @outcome.result

        @outcome = service.run(params.merge(prev_result))
        @outcome.result ||= {}
        @outcome.result = prev_result.merge(@outcome.result)
      elsif @outcome == nil
        @outcome = service.run(params)
      end

      self
    end

    # Run services in pipeline
    #
    # Example:
    #   >> LukitaService::Base.pipe(SimpleSumService, {a: 1, b: 2}).pipe(SimpleSumService, {a: 5, b: 1}).done
    #   => #<LukitaService::Result:0x00000002af4950 @valid=true, @result={:sum=>9}, @error=nil, @exception=nil>
    def self.done
      final_outcome = @outcome
      @outcome = nil
      final_outcome
    end

    private

      def self.fill_outcome(outcome)
        if outcome != nil && outcome.class == Hash
          if outcome[:valid?].nil?
            outcome[:valid?] = true
          end 

          outcome[:result] ||= {}
        else
          prev_values = outcome
          if prev_values.nil?
            prev_values = {}
          end
          outcome = {valid?: true, result: prev_values}
        end

        outcome
      end
  end
end