# Phoenix Ecto Encryption Example

![data-encrypted-cropped](https://user-images.githubusercontent.com/194400/36345569-f60382de-1424-11e8-93e9-74ed7eaceb71.jpg)

[![Build Status](https://img.shields.io/travis/dwyl/phoenix-ecto-encryption-example/master.svg?style=flat-square)](https://travis-ci.org/dwyl/phoenix-ecto-encryption-example)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/phoenix-ecto-encryption-example/master.svg?style=flat-square)](http://codecov.io/github/dwyl/phoenix-ecto-encryption-example?branch=master)
[![HitCount](http://hits.dwyl.io/dwyl/phoenix-ecto-encryption-example.svg)](https://github.com/dwyl/phoenix-ecto-encryption-example)

## Why?

**Encrypting User/Personal data** stored by your Web App is ***essential***
for security/privacy.

> If your app offers any **personalised content** or interaction
that depends on "**login**", it is **_storing_ personal data**
(_by definition_).
You might be tempted to think that
data is "safe" in a database, but it's _not_.
There is an entire ("dark") army/industry of people
([_cybercriminals_](https://en.wikipedia.org/wiki/Cybercrime))
who target websites/apps attempting to "steal" data by compromising databases.
All the time you spend _building_ your app,
they spend trying to "_break_" apps like yours.  
Don't let the people using your app
be the victims of identity theft,
protect their personal data!
(_it's both the "**right**" **thing to do** and the
 [**law**](https://github.com/dwyl/learn-security/#gdpr) ..._)

## What?

This example/tutorial is intended as a _comprehensive_ answer
to the question:

> ["_**How to Encrypt/Decrypt Sensitive Data** in `Elixir` Apps
**Before** Inserting (Saving) it into the
Database?_"](https://github.com/dwyl/learn-elixir/issues/80)

### Technical Overview

We are _not_ "re-inventing encryption"
or using our "own algorithm"
_everyone_ knows that's a "_**bad** idea_":
https://security.stackexchange.com/questions/18197/why-shouldnt-we-roll-our-own
<br />
We are _following_ a **_battle-tested_ industry-standard** approach
and applying it to our Elixir/Phoenix App. <br />
We are using:

+ **Advanced Encryption Standard** (**AES**) to encrypt sensitive data.
  + **Galois/Counter Mode**
for _symmetric_ key cryptographic block ciphers:
https://en.wikipedia.org/wiki/Galois/Counter_Mode
recommended by many security and cryptography practitioners including
 [Matthew Green](https://blog.cryptographyengineering.com/),
 [Niels Ferguson](https://en.wikipedia.org/wiki/Niels_Ferguson)
 and [Bruce Schneier](https://www.schneier.com/blog/about/)
  + "Under the hood" we are using Erlang's
[crypto](http://erlang.org/doc/man/crypto.html) library
_specifically_ AES with **256 bit keys** <br />
(_the same as AWS or Google's KMS service_)
see: http://erlang.org/doc/man/crypto.html#block_encrypt-4
+ Password "hashing" using the **Argon2**
key derivation function (KDF): https://en.wikipedia.org/wiki/Argon2 <br />
_specifically_ the Elixir implementation of `argon2`
written by David Whitlock: https://github.com/riverrun/argon2_elixir
which in turn uses the **C** "_reference implementation_"
as a "Git Submodule".

> `¯\_(ツ)_/¯...?` Don't be "put off" if any of these terms/algorithms
are _unfamiliar_ to you; <br />
this example is "***step-by-step***"
and we are _happy_ to answer/clarify
_any_ (_relevant and specific_) questions you have!

#### OWASP Cryptographic Rules?

This example/tutorial follows
the Open Web Application Security Project (**OWASP**)
Cryptographic and Password rules:
+ [x] Use "***strong approved Authenticated Encryption***"
based on an ***AES algorithm***.
  + [x] Use GCM mode of operation for symmetric key cryptographic block ciphers.
  + [x] Keys used for encryption must be rotated at least annually.
+ [x] Only use approved public algorithm **SHA-256** or better for hashing.
+ [x] **Argon2** is the winner of the password hashing competition
and should be your ***first choice*** for **_new_ applications**.

See:
+ [https://www.owasp.org/index.php/Cryptographic_Storage_Cheat_Sheet](https://www.owasp.org/index.php/Cryptographic_Storage_Cheat_Sheet#Rule_-_Use_strong_approved_Authenticated_Encryption)
+ https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet


## Who?

This example/tutorial is for _any_ developer
(_or technical decision maker / "application architect"_) <br />
who takes personal data protection _seriously_
and wants a robust/reliable and "transparent" way <br />
of _encrypting data_ `before` storing it,
and _decrypting_ when it is queried.

### Prerequisites?

+ Basic **`Elixir`** syntax knowledge: https://github.com/dwyl/learn-elixir
+ Familiarity with the **`Phoenix`** framework: https://github.com/dwyl/learn-phoenix-framework
+ Basic understanding of **`Ecto`**
(_the module used to interface with databases in elixir/phoenix_)

> If you are totally `new` to (_or "rusty" on_)
Elixir, Phoenix or Ecto,
we recommend going through our **Phoenix Chat Example**
(_Beginner's Tutorial_) _first_:
https://github.com/dwyl/phoenix-chat-example

### Crypto Knowledge?

You will _not_ need any "advanced" mathematical knowledge;
we are _not_ "inventing" our own encryption or
going into the "internals" of any cyphers/algorithms/schemes. <br />

**You do _not_ need to _understand_
how the encryption/hashing algorithms _work_,** <br />
but it is _useful_ to **know the _difference_** between
[encryption](https://en.wikipedia.org/wiki/Encryption)
vs.
[hashing](https://en.wikipedia.org/wiki/Hash_function)
and
[plaintext](https://en.wikipedia.org/wiki/Plaintext)
vs.
[ciphertext](https://en.wikipedia.org/wiki/Ciphertext).

The fact that the example/tutorial follows _all_ OWASP crypto/hashing rules
(_see:_
["OWASP Cryptographic Rules?"](https://github.com/dwyl/phoenix-ecto-encryption-example#owasp-cryptographic-rules)
_section above_),
should be "enough" for _most_ people who just want to focus
on building their app and don't want to
["_go down the rabbit hole_"](https://youtu.be/6IDT3MpSCKI?t=1m2s). <br />

_However_ ... We have included 30+ links in the
["Useful Links"](https://github.com/dwyl/phoenix-ecto-encryption-example#useful-links-faq--background-reading)
section at the _end_ of this readme.
The list includes several common questions (_and **answers**_)
so if you are _curious_, you can [learn](https://youtu.be/hOZnP4dZYK0).

> _**Note**: in the @dwyl Library we have_
https://www.schneier.com/books/applied_cryptography
_So, if you're **really curious** let us know!_

### Time Requirement?

Simply _reading_ ("_skimming_") through this example will
only take **15 minutes**. <br />
_Following_ the examples on your computer (_to fully understand it_)
will take around **1 hour** <br />
(_including reading a few of the links_).

> _**Invest** the time **up-front** to **avoid** on the **embarrassment**
and [**fines**](https://www.itgovernance.co.uk/dpa-and-gdpr-penalties)
of a data breach_.


## How?

These are "step-by-step" instructions,
don't skip any step(s).

### 1. Create the `encryption` App

In your Terminal,
***create*** a `new` Phoenix application called "encryption":
```sh
mix phx.new encryption
```

When you see `Fetch and install dependencies? [Yn]`, <br />
type `y` and press the `[Enter]` key
to download and install the dependencies. <br />
You should see following in your terminal:

```sh
* running mix deps.get
* running mix deps.compile
* running cd assets && npm install && node node_modules/webpack/bin/webpack.js --mode development

We are almost there! The following steps are missing:

    $ cd encryption

Then configure your database in config/dev.exs and run:

    $ mix ecto.create

Start your Phoenix app with:

    $ mix phx.server

You can also run your app inside IEx (Interactive Elixir) as:

    $ iex -S mix phx.server
```
Follow the _first_ instruction
**change** into the `encryption` directory: <br />
```sh
cd encryption
```

Next ***create*** the database for the App using the command:
```sh
mix ecto.create
```

You should see the following output:
```sh
Compiling 13 files (.ex)
Generated encryption app
The database for Encryption.Repo has been created
```



### 2. Create the `user` Schema (_Database Table_)

In our _example_ `user` database table,
we are going to store 3 (_primary_) pieces of data.
+ `name`: the person's name (_encrypted_)
+ `email`: their email address (_encrypted_)
+ `password_hash`: the hashed password (_so the person can login_)

In _addition_ to the 3 "_primary_" fields,
we need _**two** more fields_ to store "metadata":
+ `email_hash`: so we can check ("lookup")
if an email address is in the database
_without_ having to _decrypt_ the email(s) stored in the DB.
+ `key_id`: the id of the **encryption key** used to encrypt the data
stored in the row. As this is an `id`
we use an `:integer` to store it in the DB.<sup>1</sup>

Create the `user` schema using the following generator command:
```sh
mix phx.gen.schema User users email:binary email_hash:binary name:binary password_hash:binary key_id:integer
```

![phx.gen.schema](https://user-images.githubusercontent.com/194400/35360796-dc4507cc-0156-11e8-9cf1-7f4005e5ed34.png)


The _reason_ we are creating the encrypted/hashed fields as `:binary`
is that the _data_ stored in them will be _encrypted_
and `:binary` is the _most efficient_ Ecto/SQL data type
for storing encrypted data;
storing it as a `String` would take up more bytes
for the _same_ data.
i.e. _wasteful_ without any _benefit_ to security or performance. <br />
see:
https://dba.stackexchange.com/questions/56934/what-is-the-best-way-to-store-a-lot-of-user-encrypted-data
<br />
and: https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html

Next we need to update our newly created migration file. Open
`priv/repo/migrations/{timestamp}_create_users.exs`.

> Your migration file will
have a slightly different name to ours as migration files are named with a
timestamp when they are created but it will be in the same location.

Update the file ***from***:
```elixir
defmodule Encryption.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :binary)
      add(:email_hash, :binary)
      add(:name, :binary)
      add(:password_hash, :binary)
      add(:key_id, :integer)

      timestamps()
    end
  end
end
```

**To**

```elixir
defmodule Encryption.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :binary)
      add(:email_hash, :binary)
      add(:name, :binary)
      add(:password_hash, :binary)
      add(:key_id, :integer)

      timestamps()
    end

    create(unique_index(:users, [:email_hash]))
  end
end
```

The newly added line ensures that we will never be allowed to enter duplicate
`email_hash` values into our database.

Run the "migration" task to create the tables in the Database:
```sh
mix ecto.migrate
```

Running the `mix ecto.migrate` command will create the
`users` table in your `encryption_dev` database. <br />
You can _view_ this (_empty_) table in a PostgreSQL GUI. Here is a screenshot
from **pgAdmin**: <br />
![elixir-encryption-pgadmin-user-table](https://user-images.githubusercontent.com/194400/37981997-1ab4362a-31e7-11e8-9bd8-9566834fc199.png)


<sup>1</sup> `key_id`:
_The_ `key_id` _column in our_ `users` _database table,
indicates which **encryption key** was used to encrypt the data.
For this example/demo we are using **two** encryption keys
to **demonstrate key rotation**. Key rotation is a "**best practice**"
that **limits** the amount of data an "attacker" can decrypt
if the database were ever "compromised"
(provided we keep the encryption keys safe that is!)_


### 3. Define The 6 Functions

We need 6 functions for encrypting, decrypting, hashing and verifying
the data we will be storing:

1. **Encrypt** - to encrypt any personal data we want to store in the database.
2. **Decrypt** - decrypt any data that needs to be viewed.
3. **Get Key** - get the _latest_ encryption/decryption key
(_or a **specific** older key where data was encrypted with a different key_)
4. **Hash Email** (_deterministic & **fast**_) - so that we can "lookup"
an email without "decrypting".
The hash of an email address should _always_ be the ***same***.
5. **Hash Password** (_pseudorandom & **slow**_) - the output of the hash
should _always_ be ***different*** and relatively **slow** to compute.
6. **Verify Password** - check a password against the stored `password_hash`
to confirm that the person "logging-in" has the _correct_ password.

The next 6 sections of the example/tutorial will walk through
the creation of (_and testing_) these functions.

> _**Note**: If you have **any questions** on these functions_,
***please ask***: <br />
[github.com/dwyl/**phoenix-ecto-encryption-example/issues**](https://github.com/nelsonic/phoenix-ecto-encryption-example/issues)


#### 3.1 Encrypt

Create a file called `lib/encryption/aes.ex` and copy-paste (_or hand-write_)
the following code:

```elixir
defmodule Encryption.AES do
  @aad "AES256GCM" # Use AES 256 Bit Keys for Encryption.

  def encrypt(plaintext) do
    iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
    key = get_key()    # get the *latest* key in the list of encryption keys
    {ciphertext, tag} =
      :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
    iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
  end

  defp get_key do # this is a "dummy function" we will update it in step 3.3
    <<109, 182, 30, 109, 203, 207, 35, 144, 228, 164, 106, 244, 38, 242,
    106, 19, 58, 59, 238, 69, 2, 20, 34, 252, 122, 232, 110, 145, 54,
    241, 65, 16>> # return a random 32 Byte / 128 bit binary to use as key.
  end
end
```

The `encrypt/1` function for encrypting `plaintext` into `ciphertext`
is quite simple; (_the "body" is only 4 lines_).<br />

Let's "step through" these lines one at a time:

+ `encrypt/1` accepts one argument; the `plaintext` to be encrypted.
+ First we create a "**strong**" _random_
[***initialization vector***](https://en.wikipedia.org/wiki/Initialization_vector)
(IV) of **16 bytes** (***128 bits***)
using the Erlang's crypto library `strong_rand_bytes` function:
http://erlang.org/doc/man/crypto.html#strong_rand_bytes-1
The "IV" ensures that each time a string/block of text/data is encrypted,
the `ciphertext` is _different_.

> Having **different** `ciphertext` each time `plaintext` is encrypted
is _essential_ for
["semantic security"](https://en.wikipedia.org/wiki/Semantic_security)
whereby repeated use of the _same encryption key and algorithm_
does not allow an "attacker" to infer relationships
between segments of the encrypted message.
> [Cryptanalysis](https://en.wikipedia.org/wiki/Cryptanalysis) techniques
are _well_ "beyond scope" for this example/tutorial,
but we _highly_ encourage to check-out the "Background Reading" links
at the end and read up on the subject for deeper understanding.

+ Next we use the `get_key/0` function
to retrieve the _latest_ encryption key
so we can use it to `encrypt` the `plaintext`
(_the "real"_ `get_key/0` _is defined below in section 3.3_).

+ Then we use the Erlang `block_encrypt` function
to encrypt the `plaintext`. <br />
Using `:aes_gcm` ("_Advanced Encryption Standard Galois Counter Mode_"):
  + `@aad` is a "module attribute" (_Elixir's equivalent of a "constant"_)
  is defined in `aes.ex` as `@aad "AES256GCM"` <br />
  this simply defines the encryption mode we are using which,
  if you break down the code into 3 parts:
    + AES = Advanced Encryption Standard.
    + 256 = "256 Bit Key"
    + GCM = "Galois Counter Mode"

+ Finally we "return" the `iv` with the `ciphertag` & `ciphertext`,
this is what we store in the database.
Including the IV and ciphertag is _essential_ for allowing decryption,
without these two pieces of data, we would not be able to "reverse" the process.

> _**Note**: in addition to this_ `encrypt/1` _function,
we have defined an_ `encrypt/2` _"sister" function which accepts
a **specific** (encryption)_ `key_id` _so that we can use the desired
encryption key for encrypting a block of text.
For the purposes of this example/tutorial,
it's **not strictly necessary**,
but it is included for "completeness"_.


##### Test the `encrypt/1` Function


Create a file called `test/lib/aes_test.exs` and _copy-paste_
the following code into it:

```elixir
defmodule Encryption.AESTest do
  use ExUnit.Case
  alias Encryption.AES

  test ".encrypt includes the random IV in the value" do
    <<iv::binary-16, ciphertext::binary>> = AES.encrypt("hello")

    assert String.length(iv) != 0
    assert String.length(ciphertext) != 0
    assert is_binary(ciphertext)
  end

  test ".encrypt does not produce the same ciphertext twice" do
    assert AES.encrypt("hello") != AES.encrypt("hello")
  end
end
```

Run these two tests by running the following command:
```sh
mix test test/lib/aes_test.exs
```


> The full function definitions for AES `encrypt/1` & `encrypt/2` are in:
[`lib/encryption/aes.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/aes.ex) <br />
> And tests are in:
[`test/lib/aes_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/lib/aes_test.exs)


#### 3.2 Decrypt

The `decrypt` function _reverses_ the work done by `encrypt`;
it accepts a "blob" of `ciphertext` (_which as you may recall_),
has the IV and cypher tag prepended to it, and returns the original `plaintext`.

In the `lib/encryption/aes.ex` file, copy-paste (_or hand-write_)
the following `decrypt/1` function definition:

```elixir
def decrypt(ciphertext) do
  <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
  :crypto.block_decrypt(:aes_gcm, get_key(), iv, {@aad, ciphertext, tag})
end
```

The fist step (line) is to "split" the IV from the `ciphertext`
using Elixir's binary pattern matching.

> If you are unfamiliar with Elixir binary pattern matching syntax:
`<<iv::binary-16, tag::binary-16, ciphertext::binary>>`
read the following guide:
https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html

The `:crypto.block_decrypt(:aes_gcm, get_key(), iv, {@aad, ciphertext, tag})`
line is the _very similar_ to the `encrypt` function.

The `ciphertext` is decrypted using
[`block_decrypt/4`](http://erlang.org/doc/man/crypto.html#block_decrypt-4)
passing in the following parameters:
+ `:aes_gcm` = encyrption algorithm
+ `get_key()` =  get the encryption key used to `encrypt` the `plaintext`
+ `iv` = the original Initialisation Vector used to `encrypt` the `plaintext`
+ `{@aad, ciphertext, tag}` = a Tuple with the encryption "mode",
`ciphertext` and the `tag` that was originally used to encrypt the `ciphertext`.

Finally return _just_ the original `plaintext`.

> _**Note**: as above with the_ `encrypt/2` _function,
we have defined an_ `decrypt/2` _"sister" function which accepts
a **specific** (encryption)_ `key_id` _so that we can use the desired
encryption key for decrypting the_ `ciphertext`.
_For the purposes of this example/tutorial,
it's **not strictly necessary**,
but it is included for "completeness"_.


##### Test the `decrypt/1` Function

In the `test/lib/aes_test.exs` add the following test:

```elixir
test "decrypt/1 ciphertext that was encrypted with default key" do
  plaintext = "hello" |> AES.encrypt |> AES.decrypt()
  assert plaintext == "hello"
end
```
Re-run the tests `mix test test/lib/aes_test.exs` and confirm they pass.

> The full `encrypt` & `decrypt` function definitions with `@doc` comments
are in:
[`lib/encryption/aes.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/aes.ex)
<br />
> And tests are in:
[`test/lib/aes_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/lib/aes_test.exs)

#### 3.3 Get (Encryption) Key

You will have noticed that _both_ `encrypt` and `decrypt` functions
call a `get_key/0` function. <br />
We wrote a "dummy" function in Step 3.1,
we need to define the "real" function now!

```elixir
defp get_key do
  keys = Application.get_env(:encryption, Encryption.AES)[:keys]
  count = Enum.count(keys) - 1 # get the last/latest key from the key list
  get_key(count) # use get_key/1 to retrieve the desired encryption key.
end

defp get_key(key_id) do
  keys = Application.get_env(:encryption, Encryption.AES)[:keys] # cached call
  Enum.at(keys, key_id) # retrieve the desired key by key_id from keys list.
end
```

We define the `get_key` _twice_ in `lib/encryption/aes.ex`
as per Erlang/Elixir standard,
once for each ["arity"](https://en.wikipedia.org/wiki/Arity)
or number of "arguments".
In the first case `get_key/0` _assumes_ you want the _latest_ Encryption Key.
The second case `get_key/1` lets you supply the `key_id` to be "looked up":

Both versions of `get_key` call the `Application.get_env` function:
`Application.get_env(:encryption, Encryption.AES)[:keys]` _specifically_.
For this to work we need to define the keys as an Environment Variable
and make it available to our App in `config.exs`.

> _For the **complete** file containing these functions see_:
[`lib/encryption/aes.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/aes.ex)

##### `ENCRYPTION_KEYS` Environment Variable

In order for our `get_key/0` and `get_key/1` functions to _work_,
it needs to be able to "read" the encryption keys.

We need to "export" an Environment Variable
containing a (_comma-separated_) list of (_one or more_)
encryption key(s).

_Copy-paste_ (_and run_) the following command in your terminal:

```elixir
echo "export ENCRYPTION_KEYS='nMdayQpR0aoasLaq1g94FLba+A+wB44JLko47sVQXMg=,L+ZVX8iheoqgqb22mUpATmMDsvVGtafoAeb0KN5uWf0='" >> .env && echo ".env" >> .gitignore
```

> For _now_, copy paste this command exactly as it is.<br />
> When you are deploying your own App,
> generate your own AES encryption key(s)
> see:
[How To Generate AES Encryption Keys?](https://github.com/dwyl/phoenix-ecto-encryption-example#how-to-generate-aes-encryption-keys)
> section below for how to do this. <br />

> _**Note**: there are **two** encryption keys separated by a comma.
This is to **demonstrate** that it's **possible** to use **multiple keys**._

> _We prefer to store our Encryption Keys as
**Environment Variables** this is consistent with the "12 Factor App"
best practice:_ https://en.wikipedia.org/wiki/Twelve-Factor_App_methodology

Update the `config/config.exs` to load the environment variables from the `.env`
 file into the application. Add the following code your config file just above
 `import_config "#{Mix.env()}.exs"`:

```elixir
# run shell command to "source .env" to load the environment variables.
try do                                     # wrap in "try do"
  File.stream!("./.env")                   # in case .env file does not exist.
    |> Stream.map(&String.trim_trailing/1) # remove excess whitespace
    |> Enum.each(fn line -> line           # loop through each line
      |> String.replace("export ", "")     # remove "export" from line
      |> String.split("=", parts: 2)       # split on *first* "=" (equals sign)
      |> Enum.reduce(fn(value, key) ->     # stackoverflow.com/q/33055834/1148249
        System.put_env(key, value)         # set each environment variable
      end)
    end)
rescue
  _ -> IO.puts "no .env file found!"
end

# Set the Encryption Keys as an "Application Variable" accessible in aes.ex
config :encryption, Encryption.AES,
  keys: System.get_env("ENCRYPTION_KEYS") # get the ENCRYPTION_KEYS env variable
    |> String.replace("'", "")  # remove single-quotes around key list in .env
    |> String.split(",")        # split the CSV list of keys
    |> Enum.map(fn key -> :base64.decode(key) end) # decode the key.
```

##### Test the `get_key/0` and `get_key/1` Functions?

Given that `get_key/0` and `get_key/1` are _both_ `defp` (_i.e. "private"_)
they are not "exported" with the AES module and therefore cannot be _invoked_
outside of the AES module.

The `get_key/0` and `get_key/1` are _invoked_ by `encrypt/2` and `decrypt/2`
and thus provided these (public) latter functions
are tested adequately, the "private" functions will be too.

Re-run the tests `mix test test/lib/aes_test.exs` and confirm they _still_ pass.

> The full `encrypt` & `decrypt` function definitions with `@doc` comments
are in:
[`lib/encryption/aes.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/aes.ex)
<br />
> And tests are in:
[`test/lib/aes_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/lib/aes_test.exs)


#### 3.4 Hash _Email Address_


The idea behind _hashing_ email addresses is to
allow us to perform a _lookup_ (_in the database_) to check if the
email has _already_ been registered/used for app/system.

Imagine that `alex@example.com` has previously used your app.
The `SHA256` hash (_encoded as [base64](https://hexdocs.pm/elixir/Base.html)_)
is: `"bbYebcvPI5DkpGr0JvJqEzo77kUCFCL8euhukTbxQRA="`

`try` it for _yourself_ in `iex`:
```elixir
iex(1)> email = "alex@example.com"
"alex@example.com"
iex(2)> email_hash = :crypto.hash(:sha256, email) |> Base.encode64
"bbYebcvPI5DkpGr0JvJqEzo77kUCFCL8euhukTbxQRA="
```

If we store the `email_hash` in the database,
when `Alex` wants to _log-in_ to the App/System,
we simply perform a "lookup" in the `users` table:

```elixir
hash  = :crypto.hash(:sha256, email) |> Base.encode64
query = "SELECT * FROM users WHERE email_hash = $1"
user  = Ecto.Adapters.SQL.query!(Encryption.Repo, query, [hash])
```

> _**Note**: there's a "**built-in**" Ecto_
[`get_by`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:get_by/3) _function
to perform this type of_ <br />
``"SELECT ... WHERE field = value"`` _query **effortlessly**_

##### Generate the `SECRET_KEY_BASE`

All Phoenix apps have a `secret_key_base` for sessions.
see: http://phoenixframework.org/blog/sessions

Run the following command to generate a new phoenix secret key:

```sh
mix phx.gen.secret
```
_copy-paste_ the _output_ (64bit `String`)
into your `.env` file after the "equals sign" on the line for `SECRET_KEY_BASE`:
```yml
export SECRET_KEY_BASE={YourSecreteKeyBaseGeneratedUsing-mix_phx.gen.secret}
```

Your `.env` file should look _similar_ to:
[`.env_sample`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/.env_sample)

<!--
#### _Alternatively_ Copy The `.env_sample` File

The _easy_ way manage your Environment Variables _locally_
is to have a `.env` file in the _root_ of the project.

_Copy_ the _sample_ one:

```sh
cp .env_sample .env
```
> _**before** doing anything `else`,
ensure that `.env` is in your [`.gitignore`](https://github.com/nelsonic/phoenix-ecto-encryption-example/blob/0bc9481ab5f063e431244d915691d52103e103a6/.gitignore#L28) file._

Now update the _values_ in your `.env` file the _real_ ones for your App. <br />
-->

> _**Note**: We are using an_ `.env` _file,
but if you are using a "Cloud Platform" to deploy your app, <br />
you could consider using their "Key Management Service"
for managing encryption keys. eg_: <br />
+ Heroku:
https://github.com/dwyl/learn-environment-variables#environment-variables-on-heroku
+ AWS: https://aws.amazon.com/kms/
+ Google Cloud: https://cloud.google.com/kms/

We now need to update our config files again. Open your `config.exs` file and
change the the following:
***from***
```elixir
  secret_key_base: "3PXN/6k6qoxqQjWFskGew4r74yp7oJ1UNF6wjvJSHjC5Y5LLIrDpWxrJ84UBphJn",
  # your secret_key_base will be different but that is fine.
```

**To**
```elixir
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
```

As mentioned above, all Phoenix applications come with a `secret_key_base`.
Instead of using this default one, we have told our application to use the new
one that we added to our `.env` file.

Now we need to edit our `config/test.exs` file. Change the following:
***from***
```elixir
config :encryption, EncryptionWeb.Endpoint,
  http: [port: 4001],
  server: false
```

**To**
```elixir
config :encryption, EncryptionWeb.Endpoint,
  http: [port: 4001],
  server: false,
  secret_key_base: "3PXN/6k6qoxqQjWFskGew4r74yp7oJ1UNF6wjvJSHjC5Y5LLIrDpWxrJ84UBphJn"
```

By adding the previous code block we will now have a `secret_key_base` which
we will be able to use for testing.

Next, create a file called `lib/encryption/hash_field.ex`
and include the following code:

```elixir
defmodule Encryption.HashField do

  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt(value))
  end

  # Get/use Phoenix secret_key_base as "salt" for one-way hashing Email address
  # use the *value* to create a *unique* "salt" for each value that is hashed:
  defp get_salt(value) do
    secret_key_base =
      Application.get_env(:encryption, EncryptionWeb.Endpoint)[:secret_key_base]
    :crypto.hash(:sha256, value <> secret_key_base)
  end
end
```

The `hash/1` function use Erlang's `crypto` library
[`hash/2`](http://erlang.org/doc/man/crypto.html#hash-2) function.
+ First we tell the `hash/2` function that we want to use `:sha256`
"SHA 256" is the most widely used/recommended hash; it's both fast and "secure".
+ We then hash the `value` passed in to the `hash/1` function (_we defined_)
and _concatenate_ it with "salt" using the `get_salt/1` function
which retrieves the `secret_key_base` environment variable
and computes a ***unique*** "salt" using the value.

We use the `SHA256` one-way hash for _speed_.
We "salt" the email address so that
the hash has _some_ level of "obfuscation",
in case the DB is ever "compromised"
the "attacker" still has to "compute"
a ["rainbow table"](https://en.wikipedia.org/wiki/Rainbow_table) from _scratch_.

> _**Note**: Don't forget to export your_ `SECRET_KEY_BASE`
_environment variable_ (_see instructions above_)

> The full file containing these two functions is:
[`lib/encryption/hash_field.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/hash_field.ex) <br />
> And the tests for the functions are:
[`test/lib/hash_field_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/lib/hash_field_test.exs)



#### 3.5 Hash _Password_

When hashing **passwords**, we want to use the **_strongest_ hashing algorithm**
and we also want the hashed value (_or "digest"_) to be ***different***
each time the _same_ `plaintext` is hashed
(_unlike when hashing the email address
  where we want a deterministic digest_).

Using `argon2` makes "cracking" a password
(_in the event of the database being "compromised"
far less likely_) as is has _both_ a CPU-bound "work-factor"
_and_ a "Memory-hard" algorithm which will _significantly_
"slow down" the attacker.

##### Add the `argon2` Dependency

In order to use `argon2` we must add it to our `mix.exs` file:
in the `defp deps do` (_dependencies_) section, add the following line:

```elixir
{:argon2_elixir, "~> 1.3"},  # securely hashing & verifying passwords
```

You will need to run `mix deps.get` to install the dependency.


##### Define the `hash_password/1` Function

Create a file called `lib/encryption/password_field.ex` in your project.
The first function we need is `hash_password/1`:

```elixir
defmodule Encryption.PasswordField do

  def hash_password(value) do
    Argon2.Base.hash_password(to_string(value),
      Argon2.gen_salt(), [{:argon2_type, 2}])
  end

end
```

`hash_password/1` accepts a password to be hashed and invokes
[`Argon2.Base.hash_password/3`](https://hexdocs.pm/argon2_elixir/Argon2.Base.html#hash_password/3)
passing in 3 arguments:
+ `value` - the value (_password_) to be hashed.
+ `Argon2.gen_salt()` - the salt used to initialise the hash function
note: "behind the scenes" just
[`:crypto.strong_rand_bytes(16)`](https://github.com/riverrun/argon2_elixir/blob/d283a4f316a2a26e61f032a826ff992a480018c2/lib/argon2.ex#L76)
as we saw before in the `encrypt` function; again,
**128 bits** is considered "secure" as a hash salt or initialization vector.
+ `[{:argon2_type, 2}]` - this corresponds to `argon2id` see:
  + https://github.com/riverrun/argon2_elixir/issues/17
  + https://crypto.stackexchange.com/questions/48935/why-use-argon2i-or-argon2d-if-argon2id-exists

##### 3.5.1 Test the `hash_password/1` Function?

In order to _test_ the `PasswordField.hash_password/1` function
we use the `Argon2.verify_pass` function to _verify_ a password hash.

Create a file called `test/lib/password_field_test.exs`
and _copy-paste_ (_or hand-type_) the following test:

```elixir
defmodule Encryption.PasswordFieldTest do
  use ExUnit.Case
  alias Encryption.PasswordField, as: Field

  test "hash_password/1 uses Argon2id to Hash a value" do
    password = "EverythingisAwesome"
    hash = Field.hash_password(password)
    verified = Argon2.verify_pass(password, hash)
    assert verified
  end

end
```

Run the test using the command:

```sh
mix test test/lib/password_field_test.exs
```

The test should _pass_;
if _not_, please re-trace the steps.


#### 3.6 _Verify_ Password

The _corresponding_ function to _check_ (_or "verify"_)
the password is `verify_password/2`.
We need to supply both the `password` and `stored_hash`
(_the hash that was previously stored in the database
when the person registered or updated their password_)
It then runs `Argon2.verify_pass` which does the checking.

```elixir
def verify_password(password, stored_hash) do
  Argon2.verify_pass(password, stored_hash)
end
```

`hash_password/1` and `verify_password/2` functions are defined in:
[`lib/encryption/password_field.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/password_field.ex)


##### Test for `verify_password/2`

To test that our `verify_password/2` function works as _expected_,
open the file: `test/lib/password_field_test.exs` <br />
and add the following code to it:

```elixir
test "verify_password checks the password against the Argon2id Hash" do
  password = "EverythingisAwesome"
  hash = Field.hash_password(password)
  verified = Field.verify_password(password, hash)
  assert verified
end

test ".verify_password fails if password does NOT match hash" do
  password = "EverythingisAwesome"
  hash = Field.hash_password(password)
  verified = Field.verify_password("LordBusiness", hash)
  assert !verified
end
```

Run the tests: `mix test test/lib/password_field_test.exs`
and confirm they pass.

If you get stuck, see:
[`test/lib/password_field_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/lib/password_field_test.exs)




### 4. _Create_ `EncryptedField` Custom Ecto Type

Writing a few functions to `encrypt`, `decrypt` and `hash` data
is a good _start_, <br />
however the real "_magic_" comes from defining
these functions as Custom Ecto Types.

When we first created the Ecto Schema for our "user", in
[Step 2](https://github.com/dwyl/phoenix-ecto-encryption-example#2-create-the-user-schema-database-table)
(_above_)
This created the
[`lib/encryption/user.ex`](https://raw.githubusercontent.com/dwyl/phoenix-ecto-encryption-example/36da851f30670967dd3493f055fb9f7b2649c188/lib/encryption/user.ex)
file with the following schema:

```elixir
schema "users" do
  field :email, :binary
  field :email_hash, :binary
  field :key_id, :integer
  field :name, :binary
  field :password_hash, :binary

  timestamps()
end
```
The _default_ Ecto field types (`:binary`) are a good start.
But we can do _so much_ better if we define _custom_ Ecto Types!

Ecto Custom Types are a way of automatically "_pre-processing_" data
before inserting it into (_and reading from_) a database.
Examples of "pre-processing" include:
+ Custom Validation e.g: phone number or address format.
+ Encrypting / Decrypting
+ Hashing

A custom type expects [6 callback functions](https://hexdocs.pm/ecto/Ecto.Type.html#callbacks)
to be implemented in the file:
+ [`type/0`](https://hexdocs.pm/ecto/Ecto.Type.html#c:type/0) - define
the Ecto Type we want Ecto to use to _store_ the data
for our Custom Type. e.g: `:integer` or `:binary`
+ [`cast/1`](https://hexdocs.pm/ecto/Ecto.Type.html#c:cast/1) - "typecasts" (_converts_)
the given data to the desired type e.g: Integer to String.
+ [`dump/1`](https://hexdocs.pm/ecto/Ecto.Type.html#c:dump/1) - performs the "processing"
on the raw data before it get's "dumped" into the Ecto Native Type.
+ [`load/1`](https://hexdocs.pm/ecto/Ecto.Type.html#c:load/1) - called when
loading data from the database and receive an Ecto native type.
+ [`embed_as/1`](https://hexdocs.pm/ecto/Ecto.Type.html#c:embed_as/1) - the return value
(`:self` or `:dump`) determines how the type is treated inside embeds (not used here).
+ [`equal?/2`](https://hexdocs.pm/ecto/Ecto.Type.html#c:equal?/2) - invoked to determine
if changing a type's field value changes the corresponding database record.

Create a file called `lib/encryption/encrypted_field.ex` and add the following:

```elixir
defmodule Encryption.EncryptedField do
  alias Encryption.AES  # alias our AES encrypt & decrypt functions (3.1 & 3.2)

  @behaviour Ecto.Type  # Check this module conforms to Ecto.type behavior.
  def type, do: :binary # :binary is the data type ecto uses internally

  # cast/1 simply calls to_string on the value and returns a "success" tuple
  def cast(value) do
    {:ok, to_string(value)}
  end

  # dump/1 is called when the field value is about to be written to the database
  def dump(value) do
    ciphertext = value |> to_string |> AES.encrypt
    {:ok, ciphertext} # ciphertext is :binary data
  end

  # load/1 is called when the field is loaded from the database
  def load(value) do
    {:ok, AES.decrypt(value)} # decrypted data is :string type.
  end

  # load/2 is called with a specific key_id when the field is loaded from DB
  def load(value, key_id) do
    {:ok, AES.decrypt(value, key_id)}
  end

  # embed_as/1 dictates how the type behaves when embedded (:self or :dump)
  def embed_as(_), do: :self # preserve the type's higher level representation

  # equal?/2 is called to determine if two field values are semantically equal
  def equal?(value1, value2), do: value1 == value2
end
```

Let's step through each of these

#### `type/0`

The best data type for storing encrypted data is `:binary`
(_it uses **half** the "space" of a `:string` for the **same** ciphertext_).

#### `cast/1`

Cast any data type `to_string` before encrypting it.
(_the encrypted data "ciphertext" will be of_ `:binary` _type_)

#### `dump/1`

Calls the `AES.encrypt/1` function we defined in section 3.1 (_above_)
so data is _encrypted_ before we insert into the database.

#### `load/1`

Calls the `AES.decrypt/1` function so data is _decrypted_ when it is _read_
from the database.

#### `load/2`

Calls the `AES.decrypt/2` function so we can decrypt the `ciphertext`
using a _specific_ encryption key.
Note: Ecto does _not_ invoke this function directly,
we are using it in our `user.ex` file. (_see below_)

> _**Note**: the_ `load/2` _function is **not required**
for Ecto Type compliance.
Further reading_: https://hexdocs.pm/ecto/Ecto.Type.html

#### `embed_as/1`

This callback is only of importance when the type is part of an [embed](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-associations-embeds-and-on-replace). It's not used here,
but required for modules adopting the `Ecto.Type` behaviour as of Ecto 3.2.

#### `equal?/2`

This callback is invoked when we cast changes into a changeset and want to
determine whether the database record needs to be updated. We use a simple
equality comparison (`==`) to compare the current value to the requested
update. If both values are equal, there's no need to update the record.


_Your_ `encrypted_field.ex` Custom Ecto Type should look like this:
[`lib/encryption/encrypted_field.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/lib/encryption/encrypted_field.ex)
`try` to write the **tests** for the callback functions,
if you get "stuck", take a look at:
[`test/lib/encrypted_field_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/lib/encrypted_field_test.exs)



### 5. _Use_ `EncryptedField` Ecto Type in User Schema

Now that we have defined a Custom Ecto Type `EncryptedField`,
we can _use_ the Type in our User Schema.
Add the following line to "alias" the Type and a User
in the `lib/encryption/user.ex` file:

```elixir
alias Encryption.{EncryptedField, User}
```

Update the lines for `:email` and `:name` in the schema <br />
***from***:
```elixir
schema "users" do
  field :email, :binary
  field :email_hash, :binary
  field :key_id, :integer
  field :name, :binary
  field :password_hash, :binary

  timestamps()
end
```

**To**:
```elixir
schema "users" do
  field :email, EncryptedField
  field :email_hash, :binary
  field :key_id, :integer
  field :name, EncryptedField
  field :password_hash, :binary

  timestamps()
end
```

We need to make _two_ further changes:

_First_, we need a function to encrypt the `:email` and `:name` fields.
In the `user.ex` file add the `encrypt_fields/1`

```elixir
defp encrypt_fields(changeset) do
  case changeset.valid? do
    true ->
      {:ok, encrypted_email} = EncryptedField.dump(changeset.data.email)
      {:ok, encrypted_name} = EncryptedField.dump(changeset.data.name)
      changeset
      |> put_change(:email, encrypted_email)
      |> put_change(:name, encrypted_name)
    _ ->
      changeset
  end
end
```

_Second_, we need to _update_ the `changeset` function
to include a line calling the `encrypt_fields/1` function: <br />
***From***:
```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :email, :email_hash])
  |> validate_required([:name, :email, :email_hash])
end
```
**To**:
```elixir
def changeset(%User{} = user, attrs \\ %{}) do
  user
  |> Map.merge(attrs) # merge any attributes into
  |> cast(attrs, [:name, :email])
  |> validate_required([:name, :email])
  |> encrypt_fields   # encrypt the :name and :email fields prior to DB insert
end
```

Adding `|> Map.merge(attrs)`
to the `changeset` function will merge any additional attributes
before further checks are performed
and adding `|> encrypt_fields` will encrypt the `:name` and `:email` fields
prior to the `user` being inserted into the database.
<br />

> _**Note** we have only added the code to_ `encrypt`
_the_ `:name` _and_ `:email` _fields on the_ `changeset`.
_We still need to_ `decrypt` _the data when it is retrieved from the database._
_Decryption on data retrieval is covered below._


### 6. Create `HashField` Ecto Type for Hashing Email Address

We already added the the `hash/1` _function_ to (SHA256) hash the email address above in
[**step 3.4**](https://github.com/dwyl/phoenix-ecto-encryption-example#34-hash-email-address),
<br />
now we are going to _use_ it in an Ecto Type.

As we did for the `EncryptedField` Ecto Type in section 4 (_above_),
the `HashField` needs the same six "ecto callbacks":

+ `type/0` - `:binary` is appropriate for hashed data
+ `cast/1` - Cast any data type `to_string` before hashing it.
(_the hashed data will be stored as_ `:binary` _type_)
+ `dump/1` Calls the `hash/1` function we defined in section 3.4 (_above_).
+ `load/1` returns the `{:ok, value}` tuple (_unmodified_)
because a _hash_ cannot be "_undone_".
+ `embed_as/1` returns `:self` to preserve the type's higher level
representation.
+ `equal?/2` Performs a simple equality check by value.

The _code_ is pretty straightforward.
Update the `lib/encryption/hash_field.ex` file to:

```elixir
defmodule Encryption.HashField do
  @behaviour Ecto.Type

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    {:ok, hash(value)}
  end

  def load(value) do
    {:ok, value}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2

  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt(value))
  end

  # Get/use Phoenix secret_key_base as "salt" for one-way hashing Email address
  # use the *value* to create a *unique* "salt" for each value that is hashed:
  defp get_salt(value) do
    secret_key_base =
      Application.get_env(:encryption, EncryptionWeb.Endpoint)[:secret_key_base]
    :crypto.hash(:sha256, value <> secret_key_base)
  end
end
```


### 7. _Use_ `HashField` Ecto Type in User Schema

_First_ add the `alias` for `HashField` near the top
of the `lib/encryption/user.ex` file. e.g:
```elixir
alias Encryption.{User, Repo, EncryptedField, HashField}
```


_Next_, in the `lib/encryption/user.ex` file,
***update*** the lines for `email_hash` in the users schema<br />
***from***:
```elixir
schema "users" do
  field :email, EncryptedField
  field :email_hash, :binary
  field :key_id, :integer
  field :name, EncryptedField
  field :password_hash, :binary
  timestamps()
end
```

**To**:
```elixir
schema "users" do
  field :email, EncryptedField
  field :email_hash, HashField
  field :key_id, :integer
  field :name, EncryptedField
  field :password_hash, :binary

  timestamps()
end
```

Then we need to create a function to perform the _hashing_ of `:email` field:
```elixir
defp set_hashed_fields(changeset) do
  case changeset.valid? do
    true ->
      changeset
      |> put_change(:email_hash, HashField.hash(changeset.data.email))
    _ ->
      changeset # return unmodified
  end
end
```

_Finally_, add the `set_hashed_fields/1` function call in `changeset/2` pipeline
***from***:
```elixir
def changeset(%User{} = user, attrs \\ %{}) do
  user
  |> Map.merge(attrs) # merge any attributes into
  |> cast(attrs, [:name, :email])
  |> validate_required([:name, :email])
  |> encrypt_fields   # encrypt the :name and :email fields prior to DB insert
end
```

**To**:
```elixir
def changeset(%User{} = user, attrs \\ %{}) do
  user
  |> Map.merge(attrs)
  |> cast(attrs, [:name, :email])
  |> validate_required([:name, :email])
  |> set_hashed_fields              # set the email_hash field
  |> unique_constraint(:email_hash) # check email_hash is not already in DB
  |> encrypt_fields
end
```

We should _test_ this new functionality. Create the file
`test/lib/user_test.exs` and add the following:

```elixir

  test "inserting a user sets the :email_hash field" do
    user = Repo.insert! User.changeset(%User{}, @valid_attrs)
    assert user.email_hash == Encryption.HashField.hash(@valid_attrs.email)
  end

  test "changeset validates uniqueness of email through email_hash" do
    Repo.insert! User.changeset(%User{}, @valid_attrs) # first insert works.
    # Now attempt to insert the *same* user again:
    {:error, changeset} = Repo.insert User.changeset(%User{}, @valid_attrs)
    {:ok, message} = Keyword.fetch(changeset.errors, :email_hash)
    msg = List.first(Tuple.to_list(message))
    assert "has already been taken" == msg
  end
```

For the _full_ user tests please see:
[`test/user/user_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/user/user_test.exs)


### 8. Create `PasswordField` Ecto Type for Hashing Password

We already added the the `hash_password/1` _function_ in
[**step 3.5**](https://github.com/dwyl/phoenix-ecto-encryption-example#35-hash-password),
now we are going to _use_ it in an Ecto Type.

As for the `EncryptedField` and `HashField` Ecto Type in section 4 (_above_),
the `PasswordField` needs the same six "ecto callbacks":

+ `type/0` - `:binary` is appropriate for hashed data
+ `cast/1` - Cast any data type `to_string` before hashing it.
(_the hashed data will be stored as_ `:binary` _type_)
+ `dump/1` Calls the `hash_password/1` function
we defined in section 3.5 (_above_).
+ `load/1` returns the `{:ok, value}` tuple (_unmodified_)
because a _hash_ cannot be "_undone_".
+ `embed_as/1` returns `:self` to preserve the type's higher level
representation.
+ `equal?/2` Performs a simple equality check by value.

The _code_ is pretty straightforward.
Update the `lib/encryption/password_field.ex` file to:

```elixir
defmodule Encryption.PasswordField do
  @behaviour Ecto.Type

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    {:ok, hash_password(value)}
  end

  def load(value) do
    {:ok, value}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2

  def hash_password(value) do
    Argon2.Base.hash_password(to_string(value),
      Argon2.gen_salt(), [{:argon2_type, 2}])
  end

  def verify_password(password, stored_hash) do
    Argon2.verify_pass(password, stored_hash)
  end
end
```


### 9. _Use_ `PasswordField` Ecto Type in User Schema

As before, we need to _use_ the `PasswordField` in our User Schema.
Remember to `alias` the module at the _top_
of the `lib/encryption/user.ex` file. e.g:
```elixir
alias Encryption.{User, Repo, EncryptedField, HashField, PasswordField}
```

Now we simply _extend_ the `set_hashed_fields/1` function we defined
in part 7 (_above_) to set the `:password_hash` field on the `changeset`.
***From***:
```elixir
defp set_hashed_fields(changeset) do
  case changeset.valid? do
    true ->
      changeset
      |> put_change(:email_hash, HashField.hash(changeset.data.email))
    _ ->
      changeset # return unmodified
  end
end
```

**To**:
```elixir
defp set_hashed_fields(changeset) do
  case changeset.valid? do
    true ->
      changeset
      |> put_change(:email_hash, HashField.hash(changeset.data.email))
      |> put_change(:password_hash,
        PasswordField.hash_password(changeset.data.password))
    _ ->
      changeset # return unmodified
  end
end
```

That's it.

For the _full_ `user.ex` code see:
[`lib/encryption/user.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/tree/3659399ec32ca4f07f45d0552b9cf25c359a2456)
and tests please see:
[`test/user/user_test.exs`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/master/test/user/user_test.exs)


 <br />

### 10. Refactor `set_hashed_fields/1` and `encrypt_fields/1`...?

One of the _best_ ways to _confirm_ that you _understood_ the code
is to attempt to
[***refactor***](https://en.wikipedia.org/wiki/Code_refactoring) it.

This step is _optional_ (_you can skip it if you're not confident
with your Elixir skills_), however it is _recommended_ you at least
_read_ through it.

> _**Note**: in practice we don't tend to re-factor our code until
we have shipped it, encountered a "bottleneck" (a need for optimisation)
**or** we need to **extend** some code and want to make it "DRY" first_.

> _**Remember**: it's only "refactoring" if there are **complete tests**
otherwise it's_ ["***roulette***"](https://en.wikipedia.org/wiki/Roulette)!
(_changing code when you don't have tests,
will almost **always** result in bugs
because without tests, not all test cases are considered ..._)

In order for this refactor to succeed we need to follow these 4 steps:

1. Do not _touch_ the tests.
  + Ensure that the tests all pass before we start refactoring
  and that coverage is 100%.
  e.g: https://travis-ci.org/dwyl/phoenix-ecto-encryption-example/jobs/379887597#L833
2. Update the Schema (_to ensure the data that needs to be hashed
  is not encrypted before we try to hash it!_)
3. Create a "generic" function to perform all our data transformations
that will _replace_ `set_hashed_fields/1` and `encrypt_fields/1`.
4. Update the `changeset/2` function to _use_ the _new_ function
and remove the calls to `set_hashed_fields/1` and `encrypt_fields/1`.

#### 10.1 Ensure All Tests Pass

Typically we will create `git commit` (_if we don't already have one_)
for the "known state" where the tests were passing
(_before starting the refactor_).

The commit _before_ refactoring the example is:
https://github.com/dwyl/phoenix-ecto-encryption-example/tree/3659399ec32ca4f07f45d0552b9cf25c359a2456

The corresponding Travis-CI build for this commit is:
https://travis-ci.org/dwyl/phoenix-ecto-encryption-example/jobs/379887597#L833

> _**Note**: if you are_ `new` _to Travis-CI see_:
[https://github.com/dwyl/**learn-travis**](https://github.com/dwyl/learn-travis)

#### 10.2 Re-order `:email_hash` Field in User Schema

We need to re-order the fields in the User schema so that `:email_hash`
comes ***before*** `:email` so that the email address
is _not_ encrypted before being hashed whereby
the hash would always be different!<br />
***From***:
```elixir
schema "users" do
  field :email, EncryptedField # :binary
  field :email_hash, Encryption.HashField # :binary
  field :key_id, :integer
  field :name, EncryptedField # :binary
  field :password, :binary, virtual: true # virtual means "don't persist"
  field :password_hash, Encryption.PasswordField # :binary

  timestamps() # creates columns for inserted_at and updated_at timestamps. =)
end
```
To:
```elixir
schema "users" do
  field :email_hash, HashField # :binary
  field :email, EncryptedField # :binary
  field :key_id, :integer
  field :name, EncryptedField # :binary
  field :password, :binary, virtual: true # virtual means "don't persist"
  field :password_hash, PasswordField # :binary

  timestamps() # creates columns for inserted_at and updated_at timestamps. =)
end
```

#### 10.3 Create One Generic (DRY) Function that Replaces Two Specific (WET)

In the `user.ex` file we have _two_ functions that perform _similar_ tasks,
preparing data to be inserted into the database.
Specifically: `set_hashed_fields/1` and `encrypt_fields/1` which
perform hashing and encryption respectively.

```elixir
defp prepare_fields(changeset) do
  case changeset.valid? do # don't bother transforming the data if invalid.
    true ->
      struct = changeset.data.__struct__  # get name of Ecto Struct. e.g: User
      fields = struct.__schema__(:fields) # get list of fields in the Struct
      # create map of data transforms stackoverflow.com/a/29924465/1148249
      changes = Enum.reduce fields, %{}, fn field, acc ->
        type = struct.__schema__(:type, field)
        # only check the changeset if it's "valid" and
        if String.contains? Atom.to_string(type), "Encryption." do
          primary = case type do
            Encryption.HashField -> # "primary" field for :email_hash is :email
              :email
            Encryption.PasswordField ->
              :password
            _ ->
             field
          end
          data = Map.get(changeset.data, primary)    # get plaintext data
          {:ok, transformed_value} = type.dump(data) # dump (encrypt/hash)
          Map.put(acc, field, transformed_value)     # assign key:value to Map
        else
          acc  # always return the accumulator to avoid "nil is not a map!"
        end
      end
      %{changeset | changes: changes} # apply the changes to the changeset
    _ ->
    changeset # return the changeset unmodified for the next function in pipe
  end
end
```

This function uses
["**type introspection**"](https://en.wikipedia.org/wiki/Type_introspection)
to determine which fields are on the **Users*** struct (_schema_)
we know that hashed fields need the `plaintext` data so we
return the `primary` field for `:email` and `:password`.
then loops through those fields and determines what `dump` function
needs to be applied.
Finally we apply the `changes` to the `changeset`.


#### 10.4 Update `changeset/2` function to use `prepare_fields/1`

The last step is the easiest one. simply update the `changeset/2` function,
***from***:
```elixir
def changeset(%User{} = user, attrs \\ %{}) do
  user
  |> Map.merge(attrs)
  |> cast(attrs, [:name, :email])
  |> validate_required([:name, :email])
  |> set_hashed_fields              # set the email_hash field
  |> unique_constraint(:email_hash) # check email_hash is not already in DB
  |> encrypt_fields
end
```

**To**:
```elixir
def changeset(%User{} = user, attrs \\ %{}) do
  user
  |> Map.merge(attrs)
  |> cast(attrs, [:name, :email])
  |> validate_required([:name, :email])
  |> prepare_fields # hash and/or encrypt the personal data before db insert!
  |> unique_constraint(:email_hash) # only after the email has been hashed!
end
```

Done!
_Re-run_ the tests!
you should see:
https://travis-ci.org/dwyl/phoenix-ecto-encryption-example/builds/380557211#L833

The `user.ex` file now has _fewer_ lines of code
which are _arguably_ more maintainable.
The _end_ state of the file _after_ the refactor:
[`user.ex`](https://github.com/dwyl/phoenix-ecto-encryption-example/blob/78ddbc4a085cdb801673cfd960eab0df639009dd/lib/encryption/user.ex)

### Conclusion

We have gone through how to create custom Ecto Types
in order to define our own functions for handling
(_transforming_) specific types of data.

Our hope is that you have _understood_ the flow.

We plan to extend this tutorial include User Interface
please "star" the repo if you would find that useful.



<br /> <br />

### How To Generate AES Encryption Keys?

Encryption keys should be the appropriate length (in bits)
as required by the chosen algorithm.

> An **AES 128-bit** key can be expressed
as a hexadecimal string with 32 characters. <br />
It will require **24 characters** in **base64**.

> An **AES 256-bit** key can be expressed
as a hexadecimal string with 64 characters. <br />
It will require **44 characters** in **base64**.

see: https://security.stackexchange.com/a/45334/117318

Open `iex` in your Terminal and paste the following line (_then press enter_)
```elixir
:crypto.strong_rand_bytes(32) |> :base64.encode
```

You should see terminal output similar to the following:

![elixir-generate-encryption-key](https://user-images.githubusercontent.com/194400/38561017-dd93d186-3cce-11e8-91cd-c70f920ac79a.png)

We generated 3 keys for demonstration purposes:
+ "h6pUk0ZccS0pYsibHZZ4Cd+PRO339rMA7sMz7FnmcGs="
+ "nMd/yQpR0aoasLaq1g94FL/a+A+wB44JLko47sVQXMg="
+ "L+ZVX8iheoqgqb22mUpATmMDsvVGt/foAe/0KN5uWf0="



These two Erlang functions are described in:
+ http://erlang.org/doc/man/crypto.html#strong_rand_bytes-1
+ http://erlang.org/doc/man/base64.html#encode-1

Base64 encoding the bytes generated by `strong_rand_bytes`
will make the output human-readable
(_whereas bytes are less user-friendly_).


<br /> <br />

## Useful Links, FAQ & Background Reading

+ Bits and Bytes: https://web.stanford.edu/class/cs101/bits-bytes.html
+ Thinking in Ecto - Schemas and Changesets:
http://cultofmetatron.io/2017/04/22/thinking-in-ecto---schemas-and-changesets/
+ Initialization Vector Length:
https://stackoverflow.com/questions/4608489/how-to-pick-an-appropriate-iv-initialization-vector-for-aes-ctr-nopadding (128 bits is 16 bytes).
+ What is the effect of the different AES key lengths?
https://crypto.stackexchange.com/questions/3615/what-is-the-effect-of-the-different-aes-key-lengths
+ How is decryption done in AES CTR mode?: https://crypto.stackexchange.com/questions/34918/how-is-decryption-done-in-aes-ctr-mode
+ Block Cipher Counter (CTR) Mode:
https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Counter_.28CTR.29
+ Is AES-256 _weaker_ than 192 and 128 bit versions?
https://crypto.stackexchange.com/questions/5118/is-aes-256-weaker-than-192-and-128-bit-versions
+ What are the practical differences between 256-bit, 192-bit, and 128-bit AES encryption?
https://crypto.stackexchange.com/questions/20/what-are-the-practical-differences-between-256-bit-192-bit-and-128-bit-aes-enc
+ **How to Choose** an **Authenticated Encryption mode**
(_by Matthew Green cryptography professor at Johns Hopkins University_):
https://blog.cryptographyengineering.com/2012/05/19/how-to-choose-authenticated-encryption
+ How to choose an AES encryption mode (CBC ECB CTR OCB CFB)? (v. long answers, but good comparison!)
https://stackoverflow.com/questions/1220751/how-to-choose-an-aes-encryption-mode-cbc-ecb-ctr-ocb-cfb
+ AES GCM vs CTR+HMAC tradeoffs:
https://crypto.stackexchange.com/questions/14747/gcm-vs-ctrhmac-tradeoffs
+ Galois/Counter Mode for symmetric key cryptographic block ciphers:
https://en.wikipedia.org/wiki/Galois/Counter_Mode
+ What is the difference between CBC and GCM mode?
https://crypto.stackexchange.com/questions/2310/what-is-the-difference-between-cbc-and-gcm-mode
+ Ciphertext and tag size and IV transmission with AES in GCM mode:
https://crypto.stackexchange.com/questions/26783/ciphertext-and-tag-size-and-iv-transmission-with-aes-in-gcm-mode
+ How long (in letters) are encryption keys for AES?
https://security.stackexchange.com/questions/45318/how-long-in-letters-are-encryption-keys-for-aes
+ Why we can't implement AES 512 key size?
https://crypto.stackexchange.com/questions/20253/why-we-cant-implement-aes-512-key-size
+ Generate random alphanumeric string (_used for AES keys_)
https://stackoverflow.com/questions/12788799/how-to-generate-a-random-alphanumeric-string-with-erlang
+ Singular or Plural controller names?: https://stackoverflow.com/questions/35882394/phoenix-controllers-singular-or-plural
+ What's the purpose of key-rotation?
https://crypto.stackexchange.com/questions/41796/whats-the-purpose-of-key-rotation
+ Postgres Data Type for storing `bcrypt` hashed passwords: https://stackoverflow.com/questions/33944199/bcrypt-and-postgresql-what-data-type-should-be-used >> `bytea` (_byte_)
+ Do security experts recommend bcrypt? https://security.stackexchange.com/questions/4781/do-any-security-experts-recommend-bcrypt-for-password-storage/6415#6415
+ Hacker News discussion thread "***Don't use `bcrypt`***":
https://news.ycombinator.com/item?id=3724560
+ Storing Passwords in a Highly Parallelized World:
https://hynek.me/articles/storing-passwords
+ Password hashing security of argon2 versus bcrypt/PBKDF2?
https://crypto.stackexchange.com/questions/30785/password-hashing-security-of-argon2-versus-bcrypt-pbkdf2
+ The memory-hard Argon2 password hash function (ietf proposal):
https://tools.ietf.org/id/draft-irtf-cfrg-argon2-03.html
unlikely to be a "standard" any time soon...
+ Erlang Dirty Scheduler Overhead:
https://medium.com/@jlouis666/erlang-dirty-scheduler-overhead-6e1219dcc7
+ Erlang Scheduler Details and Why They Matter:
https://news.ycombinator.com/item?id=11064763
+ Why use argon2i or argon2d if argon2id exists?
https://crypto.stackexchange.com/questions/48935/why-use-argon2i-or-argon2d-if-argon2id-exists
+ Good explanation of _Custom_ Ecto Types:
https://medium.com/acutario/ecto-custom-types-a-practical-case-with-enumerize-rails-gem-b5496c2912ac
+ Consider using ETS to store encryption/decryption keys:
https://elixir-lang.org/getting-started/mix-otp/ets.html &
https://elixirschool.com/en/lessons/specifics/ets


### Running a Single Test

To run a _single_ test (_e.g: while debugging_), use the following syntax:
```sh
mix test test/user/user_test.exs:9
```
For more detail, please see: https://hexdocs.pm/phoenix/testing.html

### Ecto Validation Error format

When Ecto `changeset` validation fails,
for example if there is a "unique" constraint on email address
(_so that people cannot re-register with the same email address twice_),
Ecto returns the `changeset` with an `errors` key:

```elixir
#Ecto.Changeset<
  action: :insert,
  changes: %{
    email: <<224, 124, 228, 125, 105, 102, 38, 170, 15, 199, 228, 198, 245, 189,
      82, 193, 164, 14, 182, 8, 189, 19, 231, 49, 80, 223, 84, 143, 232, 92, 96,
      156, 100, 4, 7, 162, 26, 2, 121, 32, 187, 65, 254, 50, 253, 101, 202>>,
    email_hash: <<21, 173, 0, 16, 69, 67, 184, 120, 1, 57, 56, 254, 167, 254,
      154, 78, 221, 136, 159, 193, 162, 130, 220, 43, 126, 49, 176, 236, 140,
      131, 133, 130>>,
    key_id: 1,
    name: <<2, 215, 188, 71, 109, 131, 60, 147, 219, 168, 106, 157, 224, 120,
      49, 224, 225, 181, 245, 237, 23, 68, 102, 133, 85, 62, 22, 166, 105, 51,
      239, 198, 107, 247, 32>>,
    password_hash: <<132, 220, 9, 85, 60, 135, 183, 155, 214, 215, 156, 180,
      205, 103, 189, 137, 81, 201, 37, 214, 154, 204, 185, 253, 144, 74, 222,
      80, 158, 33, 173, 254>>
  },
  errors: [email_hash: {"has already been taken", []}],
  data: #Encryption.User<>,
  valid?: false
>
```

The `errors` part is:
```elixir
[email_hash: {"has already been taken", []}]
```
A `tuple` _wrapped_ in a `keyword list`.  

Why this construct? A changeset can have multiple errors, so they're stored as a keyword list, where the _key_ is the field, and the _value_ is the error tuple.  
The first item in the tuple is the error message, and the second is another keyword list, with additional information that we would use when mapping over the errors in order to make them more user-friendly (though here, it's empty).  
See the Ecto docs for [`add_error/4`](https://hexdocs.pm/ecto/Ecto.Changeset.html#add_error/4) and [`traverse_errors/2`](https://hexdocs.pm/ecto/Ecto.Changeset.html#traverse_errors/2) for more information.

So to _access_ the error message `"has already been taken"`
we need some pattern-matching and list popping:
```elixir
{:error, changeset} = Repo.insert User.changeset(%User{}, @valid_attrs)
{:ok, message} = Keyword.fetch(changeset.errors, :email_hash)
msg = List.first(Tuple.to_list(message))
assert "has already been taken" == msg
```
To see this in _action_ run:
```sh
mix test test/user/user_test.exs:40
```

### Stuck / Need Help?

If _you_ get "stuck", please open an issue on GitHub:
https://github.com/nelsonic/phoenix-ecto-encryption-example/issues
describing the issue you are facing with as much detail as you can.

<!--
TIL: app names in Phoneix _must_ be lowercase letters: <br />
![lower-case-app-names](https://user-images.githubusercontent.com/194400/35360087-73d69d88-0154-11e8-9f47-d9a9333d1e6c.png)
(_basic, I know, now..._)

Works with lowercase:  <br />
![second-time-lucky](https://user-images.githubusercontent.com/194400/35360183-c522063c-0154-11e8-994a-7516bc0e5c1e.png)
-->

<br /> <br />

## Credits

Inspiration/credit/thanks for this example goes to **Daniel Berkompas**
[@danielberkompas](https://github.com/danielberkompas)
for his post: <br />
https://blog.danielberkompas.com/2015/07/03/encrypting-data-with-ecto <br />

Daniel's post is for
[Phoenix `v0.14.0`](https://github.com/danielberkompas/danielberkompas.github.io/blob/c6eb249e5019e782e891bfeb591bc75f084fd97c/_posts/2015-07-03-encrypting-data-with-ecto.md)
which is quite "old" now ...<br />
therefore a few changes/updates are required. <br />
e.g: There are no more "**Models**" in Phoenix 1.3 or Ecto callbacks.

_Also_ his post only includes the "sample code"
and is _not_ a _complete_ example <br />
and does _not_ _explain_ the functions & Custom Ecto Types. <br />
Which means anyone following the post needs
to _manually_ copy-paste the code ...
and "figure out" the "gaps" themselves to make it work.<br />
We _prefer_ to include the _complete_ "**end state**"
of any tutorial (_not just "samples"_) <br />
so that _anyone_ can `git clone` and _`run`_
the code locally to _fully understand_ it.

Still, props to Daniel for his post, a _good intro_ to the topic!

<!--
I reached out to Daniel on Twitter
asking if he would accept a Pull Request
updating the post to latest version of Phoenix: <br />
[![credit-tweet](https://user-images.githubusercontent.com/194400/35771850-32b1cfba-092b-11e8-9bbf-0e693016bb76.png)](https://twitter.com/nelsonic/status/959901100760498181) <br />
If he replies I will _gladly_ create a PR.
_Meanwhile_ this example will fill in the gaps
and provide a more up-to-date example.
-->
