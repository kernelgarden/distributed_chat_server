defmodule AuthServer.Helper do
  alias AuthServer.Scheme

  def make_result(is_success, result_code) do
    Scheme.Result.new(is_success: is_success, code: Scheme.ResultCode.value(result_code))
  end
end
