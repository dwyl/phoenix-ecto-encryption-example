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
the data is "safe" in the database, but it's _not_.
There is an entire ("dark") army/industry of people
([_cybercriminals_](https://en.wikipedia.org/wiki/Cybercrime))
who target websites/apps attempting to "steal" data.
All the time you spend _building_ your app,
they spend trying to "_break_" apps like yours.  
Don't let the people using your app
be the victims of identity theft,
protect their personal data!
(_it's both the "**right**" **thing to do** and the
 [**law**](https://github.com/dwyl/learn-security/#gdpr) ..._)

## What?

This tutorial/example is intended as a _comprehensive_ answer
to the question:

> ["_**How to Encrypt/Decrypt Sensitive Data** in `Elixir` **Before** Inserting (Saving) it into the Database?_"](https://github.com/dwyl/learn-elixir/issues/80)

### Technical Overview

We are _not_ "re-inventing encryption"
or using our "own algorithm"
_everyone_ knows that's a "_**bad** idea_":
https://security.stackexchange.com/questions/18197/why-shouldnt-we-roll-our-own
<br />
We are _using_ a _battle-tested_ industry-standard approach
and applying it to our Elixir/Phoenix App. We are using:

+ Advanced Encryption Standard (AES) to encrypt sensitive data.
  + Galois/Counter Mode
for _symmetric_ key cryptographic block ciphers:
https://en.wikipedia.org/wiki/Galois/Counter_Mode
recommended many security and cryptography authorities including
 Matthew Green, Niels Ferguson and Bruce Schneier.
+ "Under the hood" we are using Erlang's
[crypto](http://erlang.org/doc/man/crypto.html) library
_specifically_ AES with a **256 bit key** (_the same as Google's KMS service_)
see: http://erlang.org/doc/man/crypto.html#block_encrypt-4
+ Password Hashing is done using **Argon2**:
https://en.wikipedia.org/wiki/Argon2
specifically: https://github.com/riverrun/argon2_elixir

Don't be "put off" if any of these are _unfamiliar_ to you;
the example is "step-by-step" and we are happy to answer/clarify
_any_ (_relevant_) questions you have.

## Who?

This example/tutorial is for _any_ developer
(_or technical decision maker / "application architect"_) <br />
who takes personal data protection seriously
and wants a robust/reliable and "transparent" way <br />
of _encrypting data_ `before` storing it,
and _decrypting_ when it is queried.

### Prerequisites?

+ Basic **`Elixir`** syntax knowledge.
+ Familiarity with the **`Phoenix`** framework.
+ Basic understanding of **`Ecto`**
(_the module used to interface with databases in elixir/phoenix_)

> If you are totally `new` to (_or "rusty" on_)
Elixir, Phoenix or Ecto,
we recommend going through our **Phoenix Chat Example**
(_Beginner's Tutorial_):
https://github.com/dwyl/phoenix-chat-example

### Crypto Knowledge?

You will _not_ need any "advanced" mathematical knowledge;
we are _not_ "inventing" our own encryption. <br />
We use existing well-tested/respected algorithms.
Specifically:
+ The Advanced Encryption Standard (AES) for _encryption_: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
+ Secure Hash Algorithm (SHA256) for hashing data
(_for fast lookups_):
https://en.wikipedia.org/wiki/Secure_Hash_Algorithms
+ Argon2 (_the "successor" to Bcrypt_) for password hashing:
https://en.wikipedia.org/wiki/Argon2

You do _not_ need to _understand_
how the encryption/hashing algorithms work, <br />
but it is _useful_ to know the _difference_ between
[encryption](https://en.wikipedia.org/wiki/Encryption)
vs.
[hashing](https://en.wikipedia.org/wiki/Hash_function)
and
[plaintext](https://en.wikipedia.org/wiki/Plaintext)
vs.
[ciphertext](https://en.wikipedia.org/wiki/Ciphertext).



## How?

These are "step-by-step" instructions,
don't skip any step(s).

### 1. Creat the `encryption` App

In your Terminal program,
**Create** a `new` Phoenix application called "encryption":
```sh
mix phx.new encryption
```
When you see `Fetch and install dependencies? [Yn]`, <br />
type `y` and press the `[Enter]` key
to download and install the dependencies. <br />
You should see following in your terminal:

```sh
* running mix deps.get
* running cd assets && npm install && node node_modules/brunch/bin/brunch build
* running mix deps.compile

We are all set! Go into your application by running:

    $ cd encryption

Then configure your database in config/dev.exs and run:

    $ mix ecto.create

Start your Phoenix app with:

    $ mix phx.server

You can also run your app inside IEx (Interactive Elixir) as:

    $ iex -S mix phx.server
```
Follow the first instruction
**change** into the `encryption` directory: <br />
```sh
cd encryption
```
then **Create** the database using the command:
```
mix ecto.create
```
You should see the following output:
```
Compiling 13 files (.ex)
Generated encryption app
The database for Encryption.Repo has been created
```



### 2. Create the `user` Schema (_Database Table_)

In our _example_ `user` database table,
we are going to store 3 pieces of data.
+ `name`: the person's name (_encrypted_)
+ `email`: their email address (_encrypted_)
+ `password_hash`: the hashed password (_so the person can login_)

In _addition_ to the 3 "_primary_" fields
we need _**two** more fields_ to store "metadata":
+ `email_hash`: so we can check ("lookup")
if an email address is in the database
_without_ having to _decrypt_ the email(s) stored in the DB.
+ `key_id`: the id of the **encryption key** used to encrypt the data
stored in the row. As this is an `id`
we use an `:integer` to store it in the DB.<sup>1</sup>

Create the `user` schema using generator command:
```sh
mix phx.gen.schema User users email:binary email_hash:binary name:binary password_hash:binary key_id:integer
```

![phx.gen.schema](https://user-images.githubusercontent.com/194400/35360796-dc4507cc-0156-11e8-9cf1-7f4005e5ed34.png)


The _reason_ we are creating the encrypted/hashed fields as `:binary`
is that the _data_ stored in them will be _encrypted_
and `:binary` is the _most efficient_ Ecto/SQL data type
for storing encrypted data;
storing it as a `String` would take up more bytes
for the _same_ data. <br />
i.e. _wasteful_ without any _benefit_. <br />
see: https://dba.stackexchange.com/questions/56934/what-is-the-best-way-to-store-a-lot-of-user-encrypted-data
<br />
and: https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html


Run the "migration" task to create the tables in the Database:
```sh
mix ecto.migrate
```

Running the `mix ecto.migrate` command will create the
`users` table in your `encryption_dev` database.
You can _view_ this (_empty_) table in pgAdmin: <br />
![elixir-encryption-pgadmin-user-table](https://user-images.githubusercontent.com/194400/37981997-1ab4362a-31e7-11e8-9bd8-9566834fc199.png)


<small>
<sup>1</sup>`key_id`:
_for this example/demo we are using a **single** encryption key,
but because we have the_ `key_id` _column in our database,
we can easily use **multiple keys** for "**key rotation**"
which is a good idea for limiting the amount
of data an "attacker" can decrypt if the database were ever "compromised"._
</small>


### 3. Define The 5 Functions

We need 4 functions for encrypting, decrypting and hashing the data:
1. **Encrypt** - to encrypt any personal data we want to store in the database.
2. **Decrypt** - decrypt any data that needs to be viewed.
3. **Get Key** - get the _latest_ encryption/decryption key
(_or a **specific** older key where data was encrypted with a different key_)
4. **Hash Email** (_deterministic & **fast**_) - so that we can "lookup"
an email without "decrypting".
The hash of an email address should _always_ be the ***same***.
5. **Hash Password** (_pseudorandom & **slow**_) - the output of the hash
should _always_ be ***different*** and relatively **slow** to compute.


> _**Note**: If you have **any questions** on these functions_,
***please ask***: <br />
[github.com/dwyl/**phoenix-ecto-encryption-example/issues**](https://github.com/nelsonic/phoenix-ecto-encryption-example/issues)


#### 3.1 Encrypt

The `encrypt` function for encrypting `plaintext`
is quite simple; (_only 4 lines_):<br />

```elixir
def encrypt(plaintext) do
  iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
  key = get_key()   # get the *latest* key in the list of encryption keys
  {ciphertext, tag} =
    :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
  iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
end
```

+ First we create a "**strong**" _random_
[***initialization vector***](https://en.wikipedia.org/wiki/Initialization_vector)
(IV) of **16 bytes** (***128 bits***)
using the Erlang's crypto library `strong_rand_bytes` function:
http://erlang.org/doc/man/crypto.html#strong_rand_bytes-1
The "IV" is ensures that each time a string/block of text/data is encrypted,
the `ciphertext`.
+ Next we use the `get_key` function
to retrieve the _latest_ encryption key
so we can use it to `encrypt` the `plaintext` (_defined below_)
+ Then we use the Erlang `block_encrypt` function to encrypt the `plaintext`.
Using `:aes_gcm` ("Advanced Encryption Standard Galois Counter Mode").
  + `@aad` is a "module attribute" (_Elixir's equivalent of a "constant"_)
  is defined in `aes.ex` as `@aad "AES256GCM"` this simply defines the
  encryption mode we are using which, if you break downt the code into 3 parts:
    + AES
    + 256 = "256 Bit Key" (_the )
    + GCM = "Galois Counter Mode"
+ Finally we "return" the `iv` with the `ciphertag` & `ciphertext`,
this string of data is what we store in the database.
Including the IV and ciphertag is _essential_ for allowing decryption,
without these two pieces of data, we would not be able to "reverse" the process.

> _**Note**: in addition to this_ `encrypt/1` _function,
we have defined an_ `encrypt/2` _"sister" function which accepts
a **specific** (encryption)_ `key_id` _so that we can use the desired
encryption key for encrypting a block of text.
For the purposes of this example/tutorial,
it's **not strictly necessary**,
but it is included for "completeness"_.


#### 3.2 Decrypt

The `decrypt` function _reverses_ the work done by `ecrypt`;
it accepts a "blob" of `ciphertext` (_which as you may recall_),
has the IV prepended to it, and returns the original `plaintext`.

```elixir
def decrypt(ciphertext) do
  <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
  :crypto.block_decrypt(:aes_gcm, get_key(), iv, {@aad, ciphertext, tag})
end
```

The fist step (line) is to "split" the IV from the `ciphertext`
using Elixir's binary pattern matching.

> If you are unfamiliar with Elixir binary pattern matching syntax
`<<iv::binary-16, tag::binary-16, ciphertext::binary>>``
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
`ciphertext` and the `tag` used to encrypt the `ciphertext`

Finally _just_ the original `plaintext` is _returned_.

> _**Note**: as above with the_ `encrypt/2` _function,
we have defined an_ `decrypt/2` _"sister" function which accepts
a **specific** (encryption)_ `key_id` _so that we can use the desired
encryption key for decrypting the_ `ciphertext`.
_For the purposes of this example/tutorial,
it's **not strictly necessary**,
but it is included for "completeness"_.


#### 3.3 Get (Encryption) Key

You will have noticed that _both_ `encrypt` and `decrypt` functions
call a `get_key()` function.
It is not a "built-in" function, we are about to define it!

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
the second case `get_key/1` lets you supply the `key_id` to be "looked up":



##### `ENCRYPTION_KEYS` Environment Variable

In order for our `get_key/0` and `get_key/1` functions to work,
it needs to be know how to "read" the encryption keys.

> _**Note**: we prefer to store our Encryption Keys as
**Environment Variables** this is consistent with the "12 Factor App"
best practice:_

e need to "export" an Environment Variable
containing a (_comma-separated_) list of (_one or more_)
encryption key(s).
_Copy-paste_ (_and run_) the following command in your terminal:

```elixir
echo "export ENCRYPTION_KEYS='nMdayQpR0aoasLaq1g94FLba+A+wB44JLko47sVQXMg=,L+ZVX8iheoqgqb22mUpATmMDsvVGtafoAeb0KN5uWf0='" >> .env && echo ".env" >> .gitignore
```
> For _now_, copy paste this command exactly as it is.<br />
> When you are deploying your own App,
> generate your own AES encryption key(s)
> see below for how to do this.
> _**Note**: there are **two** encryption keys separated by a comma.
This is to **demonstrate** that it's **possible** to use **multiple keys**._


```elixir

```



https://elixirschool.com/en/lessons/specifics/ets/
https://elixir-lang.org/getting-started/mix-otp/ets.html



In your terminal run the following **_three_ commands**:



```sh


```

As noted above, we want the _ability_ to "_rotate_" our encryption keys.
As such we need the ability to have a _list_
of encryption keys we can select from.
(_if you just want to see the example in action,
  and not bother with setting up any Environment Variables with multiple keys,
  skip to the next function_)

```

```



#### 3.3.a

#### Copy The `.env_sample` File

The _easy_ way manage your Environment Variables _locally_
is to have a `.env` file in the _root_ of the project.

_Copy_ the _sample_ one:

```sh
cp .env_sample .env
```
> _**before** doing anything `else`,
ensure that `.env` is in your [`.gitignore`](https://github.com/nelsonic/phoenix-ecto-encryption-example/blob/0bc9481ab5f063e431244d915691d52103e103a6/.gitignore#L28) file._

Now update the _values_ in your `.env` file the _real_ ones for your App. <br />


> Note: if you are using a "Cloud Platform" to deploy your app,
you could consider using their "Key Management Service"
for managing encryption keys. eg: <br />
+ https://aws.amazon.com/kms/
+ https://cloud.google.com/kms/

#### Generate the `SECRET_KEY_BASE`

Run the following command to generate a new phoenix secret key:

```sh
mix phx.gen.secret
```
_copy-paste_ the _output_ (64bit `String`)
into your `.env` file after the "equals sign" on the line for `SECRET_KEY_BASE`:
```yml
export SECRET_KEY_BASE=YourSecreteKeyBaseGeneratedUsing-mix_phx.gen.secret
```



#### 3.4 Hash _Email Address_

This is one-way and designed for _speed_.
We "salt" the email address so that
the hash has _some_ level of "obfuscation",
in case the DB is ever "compromised"
the "attacker" still has to "compute" a "rainbow table"
from _scratch_.

#### 3.5 Hash _Password_

Using `bcrypt` makes "cracking" a password
(_in the event of the database being "compromised"
far less likely_) as `bcrypt` has a CPU-bound "work-factor".




### How To Generate AES Encryption Keys?

Encryption keys should be the appropriate length (in bits)
as required by the chosen algorithm.

> An **AES 128-bit** key can be expressed
as a hexadecimal string with 32 characters.
It will require **24 characters** in **base64**.

> An **AES 256-bit** key can be expressed
as a hexadecimal string with 64 characters.
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
+ Ciphertext and tag size and IV transmission with AES in GCM mode:
https://crypto.stackexchange.com/questions/26783/ciphertext-and-tag-size-and-iv-transmission-with-aes-in-gcm-mode
+ How long (in letters) are encryption keys for AES?
https://security.stackexchange.com/questions/45318/how-long-in-letters-are-encryption-keys-for-aes
+ Why we can't implement AES 512 key size?
https://crypto.stackexchange.com/questions/20253/why-we-cant-implement-aes-512-key-size
+ Generate random alphanumeric string (_used for AES keys_)
https://stackoverflow.com/questions/12788799/how-to-generate-a-random-alphanumeric-string-with-erlang
+ Singular or Plural controller names?: https://stackoverflow.com/questions/35882394/phoenix-controllers-singular-or-plural
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

## Troubleshooting

If _you_ get "stuck", please open an issue on GitHub:
https://github.com/nelsonic/phoenix-ecto-encryption-example/issues
describing the issue you are facing with as much detail as you can.

TIL: app names in Phoneix _must_ be lowercase letters: <br />
![lower-case-app-names](https://user-images.githubusercontent.com/194400/35360087-73d69d88-0154-11e8-9f47-d9a9333d1e6c.png)
(_basic, I know, now..._)

Works with lowercase:  <br />
![second-time-lucky](https://user-images.githubusercontent.com/194400/35360183-c522063c-0154-11e8-994a-7516bc0e5c1e.png)

### Running a Single Test

To run a _single_ test while debugging, use the following syntax:
```sh
mix test test/user/user_test.exs:9
```

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
A `tuple` _wrapped_ in a `list`.
(_no idea why this construct, but there must be a **reason** somewhere..._)

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


<br /> <br />

## Credits

Credit for this example goes to [@danielberkompas](https://github.com/danielberkompas)
for his post:
https://blog.danielberkompas.com/2015/07/03/encrypting-data-with-ecto <br />

Daniel's post is for [Phoenix `v0.14.0`](https://github.com/danielberkompas/danielberkompas.github.io/blob/c6eb249e5019e782e891bfeb591bc75f084fd97c/_posts/2015-07-03-encrypting-data-with-ecto.md) which is quite "old" now ...
therefore a few changes/updates are required.
e.g: There are no more "**Models**" in Phoenix 1.3 or Ecto callbacks.

_Also_ his post only includes the "sample code"
and is _not_ a _complete_ example
_explaining_ the functions & Custom Ecto Types. <br />
Which means anyone following the post needs to _manually_ copy-paste the code...
We prefer to include the _complete_ "end state" of any tutorial so that
people can `git clone` and _`run`_ the code locally.

<!--
I reached out to Daniel on Twitter
asking if he would accept a Pull Request
updating the post to latest version of Phoenix: <br />
[![credit-tweet](https://user-images.githubusercontent.com/194400/35771850-32b1cfba-092b-11e8-9bbf-0e693016bb76.png)](https://twitter.com/nelsonic/status/959901100760498181) <br />
If he replies I will _gladly_ create a PR.
_Meanwhile_ this example will fill in the gaps
and provide a more up-to-date example.
-->
