defmodule Transaction do
  use Rustler, otp_app: :transaction, crate: :transaction

  @typedoc """
  Type representing a public key or address string in base58 format.
  """
  @type address :: String.t()

  @typedoc """
  Type representing a private key in hexadecimal format.
  """
  @type private_key :: String.t()

  @typedoc """
  Type representing an amount in lamports (smallest unit of SOL).
  """
  @type amount :: non_neg_integer()

  @typedoc """
  Type representing a transaction signature.
  """
  @type signature :: String.t()

  @doc """
  Retrieves the RPC client URL from the configuration.

  ## Returns

    * `{:ok, String.t()}` - The RPC client URL on success
    * `{:error, String.t()}` - Error message if configuration cannot be loaded

  ## Examples

      iex> Transaction.read_rpc_client()
      {:ok, "http://localhost:8899"}
  """
  @spec read_rpc_client() :: {:ok, String.t()} | {:error, String.t()}
  def read_rpc_client do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
  Creates, signs, and sends a transaction on the Solana blockchain.

  ## Parameters

    * `sender` - The sender's public key in base58 format
    * `recipient` - The recipient's public key in base58 format
    * `amount` - The amount to send in lamports
    * `private_key_hex` - The sender's private key in hexadecimal format

  ## Returns

    * `{:ok, signature}` - Transaction signature if successful
    * `{:error, String.t()}` - Error message if the transaction fails

  ## Examples

      iex> Transaction.make_transaction(
      ...>   "sender_address",
      ...>   "recipient_address",
      ...>   1_000_000,
      ...>   "private_key_hex"
      ...> )
      {:ok, "transaction_signature"}
  """
  @spec make_transaction(address(), address(), amount(), private_key()) ::
          {:ok, signature()} | {:error, String.t()}
  def make_transaction(_sender, _recipient, _amount, _private_key_hex) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
