defmodule Transaction do
  use Rustler, otp_app: :transaction, crate: :transaction

  @spec read_rpc_client() :: {:ok, String.t()} | {:error, String.t()}
  def read_rpc_client() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def hello do
    :world
  end
end
