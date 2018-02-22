defmodule Encryption.AES do
  @moduledoc """
  Encrypt values with AES in CTR mode, using a random Initialisation Vector
  for each encryption, this makes "bruteforce" decryption much more difficult.
  See `encrypt/1` and `decrypt/1` for more details.
  """
  @aad "AES256GCM"

  @doc """
  Encrypt a value. Uses a random IV for each call, and prepends the IV to the
  ciphertext.  This means that `encrypt/1` will never return the same ciphertext
  for the same value. This makes "cracking" (bruteforce decryption) much harder!
  ## Parameters
  - `plaintext`: Accepts any data type as all values are converted to a String
    using `to_string` before encryption.
  ## Examples
      iex> Encryption.AES.encrypt("test") != Encryption.AES.encrypt("test")
      true
      iex> ciphertext = Encryption.AES.encrypt(123)
      ...> is_binary(ciphertext)
      true
  """
  @spec encrypt(any) :: String.t
  def encrypt(plaintext) do
    iv    = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
    state = :crypto.stream_init(:aes_ctr, get_key(), iv) # create crypto stream
    # peform the encryption:
    {_state, ciphertext} = :crypto.stream_encrypt(state, to_string(plaintext))
    iv <> ciphertext # "return" iv concatenated with the ciphertext
  end

  @doc """
  Decrypt a binary.

  ## Parameters
  - `ciphertext`: a binary to decrypt, assuming that the first 16 bytes of the
    binary are the IV to use for decryption.
  - `key_id`: the index of the AES encryption key used to encrypt the ciphertext
  ## Example
      iex> Encryption.AES.encrypt("test") |> Encryption.AES.decrypt(1)
      "test"
  """
  @spec decrypt(String.t, number) :: {String.t, number}
  def decrypt(ciphertext, key_id) do
    <<iv::binary-16, ciphertext::binary>> = ciphertext # split iv & ciphertext
    # get encryption key based on key_id & Initialise crypto stream:
    state = :crypto.stream_init(:aes_ctr, get_key(key_id), iv)
    # perform decryption
    {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
    plaintext # "return" just the plaintext
  end

  # as above but *asumes* `default` (latest) encryption key is used.
  def decrypt(ciphertext) do
    <<iv::binary-16, ciphertext::binary>> = ciphertext # split iv & ciphertext
    # get encryption key based on key_id & Initialise crypto stream:
    state = :crypto.stream_init(:aes_ctr, get_key(), iv)
    # perform decryption
    {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
    plaintext # "return" just the plaintext
  end


  defp get_key do
    keys = Application.get_env(:encryption, Encryption.AES)[:keys]
    count = Enum.count(keys) - 1
    get_key(count)
  end

  # @doc """
  # get_key - Get encryption key from list of keys.
  # if `key_id` is *not* supplied as argument,
  # then the default *latest* encryption key will be returned.
  # ## Parameters
  # - `key_id`: the index of AES encryption key used to encrypt the ciphertext
  # ## Example
  #     iex> Encryption.AES.get_key
  #     <<13, 217, 61, 143, 87, 215, 35, 162, 183, 151, 179, 205, 37, 148>>
  # """ # doc commented out because https://stackoverflow.com/q/45171024/1148249
  @spec get_key(number) :: number
  defp get_key(key_id) do
    keys = Application.get_env(:encryption, Encryption.AES)[:keys]
    Enum.at(keys, key_id)
  end

  @doc """
  Encrypt Using AES Galois/Counter Mode (GCM)
  https://en.wikipedia.org/wiki/Galois/Counter_Mode
  Uses a random IV for each call, and prepends the IV to the
  ciphertext.  This means that `encrypt/1` will never return the same ciphertext
  for the same value. This makes "cracking" (bruteforce decryption) much harder!
  ## Parameters
  - `plaintext`: Accepts any data type as all values are converted to a String
    using `to_string` before encryption.
  ## Examples
      iex> Encryption.AES.encrypt("test") != Encryption.AES.encrypt("test")
      true
      iex> ciphertext = Encryption.AES.encrypt(123)
      ...> is_binary(ciphertext)
      true
  """
  @spec encrypt_gcm(any, number) :: {String.t, number}
  def encrypt_gcm(plaintext, key_id) do
    IO.inspect plaintext, label: "plaintext"
    iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
    IO.inspect iv, label: "iv"
    key = get_key(key_id)
    {ciphertext, tag} =
      :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, plaintext, 16})

    IO.inspect tag, label: "tag"
    # {:ok, Encoder.encode(tag) <> iv <> ciphertag <> ciphertext}
    iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
  end

  def encrypt_gcm(plaintext) do
    IO.inspect plaintext, label: "plaintext"
    iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
    IO.inspect iv, label: "iv"
    key = get_key()
    {ciphertext, tag} =
      :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, plaintext, 16})

    IO.inspect tag, label: "tag"
    # {:ok, Encoder.encode(tag) <> iv <> ciphertag <> ciphertext}
    iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
  end

  @doc """
  Decrypt a binary using GCM

  ## Parameters
  - `ciphertext`: a binary to decrypt, assuming that the first 16 bytes of the
    binary are the IV to use for decryption.
  - `key_id`: the index of the AES encryption key used to encrypt the ciphertext
  ## Example
      iex> Encryption.AES.encrypt("test") |> Encryption.AES.decrypt(1)
      "test"
  """
  @spec decrypt_gcm(String.t, number) :: {String.t, number}
  def decrypt_gcm(ciphertext, key_id) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext

    IO.inspect key_id, label: "key_id"
    IO.inspect iv, label: "iv2"
    IO.inspect tag, label: "tag2"
    IO.inspect ciphertext, label: "ciphertext"

    :crypto.block_decrypt(
      :aes_gcm,
      get_key(key_id),
      iv,
      {@aad, ciphertext, tag}
    )
  end

  # as above but *asumes* `default` (latest) encryption key is used.
  def decrypt_gcm(ciphertext) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    :crypto.block_decrypt(:aes_gcm, get_key(), iv, {@aad, ciphertext, tag})
  end
end
