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

  @typedoc """
  Type representing blockhash string.
  """
  @type blockhash :: String.t()

  @typedoc """
  Type representing a transaction in hex format.
  """
  @type transaction_hex :: String.t()

  @doc """
  Creates and signs a transaction.

  ## Parameters

    * `sender` - The sender's public key in base58 format
    * `recipient` - The recipient's public key in base58 format
    * `amount` - The amount to send in lamports
    * `private_key_hex` - The sender's private key in hexadecimal format
    * `recent_blockhash` - Recent blockhash from the network

  ## Returns

    * `{:ok, transaction_hex}` - Signed transaction in hex format
    * `{:error, String.t()}` - Error message if the creation fails
  """
  @spec create_and_sign_transaction(address(), address(), amount(), private_key(), blockhash()) ::
          {:ok, transaction_hex()} | {:error, String.t()}
  def create_and_sign_transaction(
        _sender,
        _recipient,
        _amount,
        _private_key_hex,
        _recent_blockhash
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
  Mints a new NFT on the Solana blockchain.

  ## Parameters

    * `creator_key` - The creator's private key in base58 format
    * `name` - The name of the NFT
    * `symbol` - The symbol of the NFT
    * `uri` - The URI pointing to the NFT's metadata
    * `recent_blockhash` - Recent blockhash from the network
    * `mint_rent` - The rent exemption amount for the mint account

  ## Returns

    * `{:ok, transaction_hex}` - NFT mint hex in hex format
    * `{:error, String.t()}` - Error message if the creation fails
  """
  @spec create_mint_nft_transaction(
          private_key(),
          String.t(),
          String.t(),
          String.t(),
          blockhash(),
          non_neg_integer()
        ) ::
          {:ok, transaction_hex()} | {:error, String.t()}
  def create_mint_nft_transaction(
        _creator_key,
        _name,
        _symbol,
        _uri,
        _recent_blockhash,
        _mint_rent
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
    Returns the RPC URL for the Solana blockchain.

    ## Returns
    * `{:ok, String.t()}` - RPC URL
    * `{:error, String.t()}` - Error message if the retrieval fails
  """
  @spec get_rpc_url() :: {:ok, String.t()} | {:error, String.t()}
  def get_rpc_url() do
    Config.get_rpc_url()
  end

  @doc """
  Gets a recent blockhash from the Solana network.

  ## Parameters
    * `rpc_url` - The RPC server URL

  ## Returns
    * `{:ok, blockhash}` - Recent blockhash if successful
    * `{:error, String.t()}` - Error message if the request fails
  """
  @spec get_recent_blockhash(String.t()) :: {:ok, blockhash()} | {:error, String.t()}
  def get_recent_blockhash(rpc_url) do
    payload = %{
      jsonrpc: "2.0",
      id: 1,
      method: "getLatestBlockhash",
      params: []
    }

    case HTTPoison.post(rpc_url, Jason.encode!(payload), [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"result" => %{"value" => %{"blockhash" => blockhash}}}} -> {:ok, blockhash}
          _ -> {:error, "Failed to parse blockhash response"}
        end

      _ ->
        {:error, "Failed to fetch recent blockhash"}
    end
  end

  @doc """
  Gets the minimum rent for a mint account.

  ## Parameters
    * `rpc_url` - The RPC server URL

  ## Returns
    * `{:ok, mint_rent}` - Mint rent amount if successful
    * `{:error, String.t()}` - Error message if the request fails
  """
  @spec get_mint_rent(String.t()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def get_mint_rent(rpc_url) do
    payload = %{
      jsonrpc: "2.0",
      id: 1,
      method: "getMinimumBalanceForRentExemption",
      params: [82]
    }

    case HTTPoison.post(rpc_url, Jason.encode!(payload), [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"result" => mint_rent}} when is_integer(mint_rent) -> {:ok, mint_rent}
          _ -> {:error, "Failed to parse mint rent response"}
        end

      _ ->
        {:error, "Failed to fetch mint rent"}
    end
  end

  @doc """
  Makes a full transaction from creation to sending.

  ## Parameters
  * `sender` - The sender's public key in base58 format
  * `recipient` - The recipient's public key in base58 format
  * `amount` - The amount to send in lamports
  * `private_key_hex` - The sender's private key in hexadecimal format

  ## Returns
  * `{:ok, signature}` - Transaction signature if successful
  * `{:error, String.t()}` - Error message if the transaction fails
  """
  @spec make_transaction(address(), address(), amount(), private_key()) ::
          {:ok, signature()} | {:error, String.t()}
  def make_transaction(sender, recipient, amount, private_key_hex) do
    # TODO: Send Transaction
    with {:ok, rpc_url} <- get_rpc_url(),
         {:ok, recent_blockhash} <- get_recent_blockhash(rpc_url),
         {:ok, tx_hex} <-
           create_and_sign_transaction(
             sender,
             recipient,
             amount,
             private_key_hex,
             recent_blockhash
           ) do
      {:ok, tx_hex}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Mints a new NFT on the Solana blockchain.

  ## Parameters
    * `creator_key` - The creator's private key in base58 format
    * `name` - The name of the NFT
    * `symbol` - The symbol of the NFT
    * `uri` - The URI pointing to the NFT's metadata

  ## Returns
    * `{:ok, signature}` - Transaction signature if successful
    * `{:error, String.t()}` - Error message if the minting fails
  """
  @spec mint_nft(private_key(), String.t(), String.t(), String.t()) ::
          {:ok, signature()} | {:error, String.t()}
  def mint_nft(creator_key, name, symbol, uri) do
    # TODO: Send Transaction
    with {:ok, rpc_url} <- get_rpc_url(),
         {:ok, blockhash} <- get_recent_blockhash(rpc_url),
         {:ok, mint_rent} <- get_mint_rent(rpc_url),
         {:ok, tx_hex} <-
           create_mint_nft_transaction(creator_key, name, symbol, uri, blockhash, mint_rent) do
      {:ok, tx_hex}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    Sends a signed transaction to the Solana network.

    ## Parameters
    * `transaction_hex` - The signed transaction in hex format
    * `rpc_url` - The RPC server URL

    ## Returns
    * `{:ok, signature}` - Transaction signature if successful
    * `{:error, String.t()}` - Error message if the sending fails
  """
  @spec send_transaction(transaction_hex(), String.t()) ::
          {:ok, signature()} | {:error, String.t()}
  def send_transaction(transaction_hex, rpc_url) do
    transaction_base64 =
      transaction_hex
      |> String.codepoints()
      |> Enum.chunk_every(2)
      |> Enum.map(fn [a, b] -> String.to_integer(a <> b, 16) end)
      |> :binary.list_to_bin()
      |> Base.encode64()

    payload = %{
      jsonrpc: "2.0",
      id: 1,
      method: "sendTransaction",
      params: [transaction_base64, %{encoding: "base64"}]
    }

    case HTTPoison.post(rpc_url, Jason.encode!(payload), [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"result" => signature}} when is_binary(signature) ->
            {:ok, signature}

          {:ok, %{"error" => %{"message" => message}}} ->
            {:error, "RPC error: #{message}"}

          _ ->
            {:error, "Failed to parse send transaction response"}
        end

      _ ->
        {:error, "Failed to send transaction"}
    end
  end
end
