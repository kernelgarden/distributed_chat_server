defmodule AuthServer.Helper do
  alias AuthServer.Scheme

  def make_result(is_success, result_code) do
    Scheme.Result.new(is_success: is_success, code: Scheme.ResultCode.value(result_code))
  end

  @spec make_rand_string(non_neg_integer()) :: binary()
  def make_rand_string(length \\ 64) do
    :crypto.strong_rand_bytes(length)
    |> :base64.encode()
  end
end
