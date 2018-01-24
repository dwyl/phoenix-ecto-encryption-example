defmodule Encryption.AES do
  @moduledoc """
  Encrypt values with AES in CTR mode, using random IVs for each encryption.
  See `encrypt/1` and `decrypt/1` for more details.
  """

  @doc """
  Encrypt a value. Uses a random IV for each call, and prepends the IV to the
  ciphertext.  This means that `encrypt/1` will never return the same ciphertext
  for the same value.
  ## Parameters
  - `plaintext`: Any type. Will be converted to a string using `to_string`
    before encryption.
  ## Examples
      iex> Encryption.AES.encrypt("test") != Encryption.AES.encrypt("test")
      true
      iex> ciphertext = Encryption.AES.encrypt(123)
      ...> is_binary(ciphertext)
      true
  """
  @spec encrypt(any) :: String.t
  def encrypt(plaintext) do
    iv    = :crypto.strong_rand_bytes(16)
    state = :crypto.stream_init(:aes_ctr, key, iv)

    {_state, ciphertext} = :crypto.stream_encrypt(state, to_string(plaintext))
    iv <> ciphertext
  end

  @doc """
  Decrypt a binary.

  ## Parameters
  - `ciphertext`: a binary to decrypt, assuming that the first 16 bytes of the
    binary are the IV to use for decryption.
  ## Example
      iex> Encryption.AES.encrypt("test") |> Encryption.AES.decrypt
      "test"
  """
  @spec decrypt(String.t) :: String.t
  def decrypt(ciphertext) do
    <<iv::binary-16, ciphertext::binary>> = ciphertext
    state = :crypto.stream_init(:aes_ctr, key, iv)

    {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
    plaintext
  end

  defp key do
    Application.get_env(:encryption, Encryption.AES)[:key]
  end
end
