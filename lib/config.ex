defmodule Config do
    @moduledoc """
    Module for handling configuration settings for the Transaction module.
    Loads configuration from config.yaml file.
    """
    @config_file "config.yaml"

    @doc """
        Loads the configuration from the config file.

    ## Returns
    * `{:ok, config}` - Configuration map if successful
    * `{:error, String.t()}` - Error message if loading fails
    """
    @spec load() :: {:ok, map()} | {:error, String.t()}
    def load() do
        case File.read(@config_file) do
            {:ok, content} ->
            case YamlElixir.read_from_string(content) do
                {:ok, config} when is_map(config) -> {:ok, config}
                {:error, reason} -> {:error, "Failed to parse YAML: #{inspect(reason)}"}
            end
            {:error, reason} -> {:error, "Failed to read config file: #{inspect(reason)}"}
        end
    end

    @doc """
    Gets the RPC URL from the configuration.

    ## Returns
    * `{:ok, String.t()}` - RPC URL if successful
    * `{:error, String.t()}` - Error Message if loading fails
    end
    """
    @spec get_rpc_url() :: {:ok, String.t()} | {:error, String.t()}
    def get_rpc_url() do
        # with {:ok, config} <- load(),
            # {:ok, rpc_url} <
    end

    @doc """
    Gets a specific value from the configuration.

    ## Parameters
    * `config` - The configuration map
    * `path` - List of keys to traverse to find the value

    ## Returns
    * `{:ok, any()}` - Value if found
    * `{:error, String.t()}` - Error message if not found
    """
    @spec get_in_config(map(), list(String.t())) :: {:ok, any()} | {:error, String.t()}
    def get_in_config(config, path) do
        case get_in_path(config, path) do
            nil -> {:error, "Config value not found at path: #{inspect(path)}"}
            value -> {:ok, value}
        end
    end

    defp get_in_path(map, []), do: map
    defp get_in_path(map, [key | rest]) when is_map(map) do
        case Map.get(map, key) do
            nil -> nil
            value -> get_in_path(value, rest)
        end
    end
    defp get_in_path(_, _), do: nil

end
