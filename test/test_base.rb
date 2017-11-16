require 'minitest/autorun'
require 'lukita_service'



class BaseTest < Minitest::Test
  class SumService < LukitaService::Base
    def self.execute(params)
      num1 = params[:a]
      num2 = params[:b]
      sum = params[:sum]
      sum ||= 0

      if num1 != nil && num2 != nil
        { valid?: true, result: { sum: num1 + num2 + sum }}
      else
        { valid?: false, error: "invalid numbers"}
      end
    end
  end

  class SimpleSumService < LukitaService::Base
    def self.execute(params)
      num1 = params[:a]
      num2 = params[:b]
      sum = params[:sum]

      num1 ||= 0
      num2 ||= 0
      sum ||= 0

      { result: { sum: num1 + num2 + sum }}
    end
  end

  class SimpleLogService < LukitaService::Base
    def self.execute(params)
      puts "lukita bacana"
    end
  end

  def test_run
    result = SumService.run(a: 1, b: 2)
    
    assert result.valid? == true
    assert result.result[:sum] == 3
    assert result.error == nil
    assert result.exception == nil
  end

  def test_run_simple_log
    result = SimpleLogService.run

    assert result.valid? == true
    assert result.result == {}
    assert result.error == nil
    assert result.exception == nil
  end

  def test_run_invalid_params
    result = SumService.run

    assert result.valid? == false
    assert result.result == {}
    assert result.error == "invalid numbers"
    assert result.exception == nil
  end

  def test_pipe_and_done
    result = LukitaService::Base
      .pipe(SumService, {a: 1, b: 2}) # 3
      .pipe(SumService, {a: 5, b: 1}) # 3 + 6 = 9
      .done

    assert result.valid? == true
    assert result.result[:sum] == 9
    assert result.error == nil
    assert result.exception == nil
  end

  def test_pipe_and_done_invalid
    result = LukitaService::Base
      .pipe(SumService, {a: 1, b: 2}) # 3
      .pipe(SumService)
      .done

    assert result.valid? == false
    assert result.result[:sum] == 3
    assert result.error == "invalid numbers"
    assert result.exception == nil
  end

  def test_pipe_and_done_invalid_all
    result = LukitaService::Base
      .pipe(SumService)
      .pipe(SumService)
      .done

    assert result.valid? == false
    assert result.result == {}
    assert result.error == "invalid numbers"
    assert result.exception == nil
  end

  def test_pipe_and_done_simple
    result = LukitaService::Base
      .pipe(SimpleSumService, {a: 1, b: 2}) # 3
      .pipe(SimpleSumService, {a: 5, b: 1}) # 3 + 6 = 9
      .done

    assert result.valid? == true
    assert result.result[:sum] == 9
    assert result.error == nil
    assert result.exception == nil
  end

  def test_pipe_and_done_with_log
    result = LukitaService::Base
      .pipe(SimpleSumService, {a: 1, b: 2}) # 3
      .pipe(SimpleLogService)
      .pipe(SimpleSumService, {a: 5, b: 1}) # 3 + 6 = 9
      .done

    assert result.valid? == true
    assert result.result[:sum] == 9
    assert result.error == nil
    assert result.exception == nil
  end
end