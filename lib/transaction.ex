defmodule Transaction do
  use Rustler, otp_app: :transaction, crate: :transaction

  @spec add(integer(), integer()) :: integer()
  def add(_, _) do
      :erlang.nif_error(:nif_not_loaded)
  end

  def hello do
    :world
  end
end
