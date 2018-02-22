# Phoenix Ecto Encryption Example

![data-encrypted-cropped](https://user-images.githubusercontent.com/194400/36345569-f60382de-1424-11e8-93e9-74ed7eaceb71.jpg)

[![Build Status](https://travis-ci.org/nelsonic/phoenix-ecto-encryption-example.svg?branch=master)](https://travis-ci.org/nelsonic/phoenix-ecto-encryption-example)

## Why?

**Encrypting User/Personal data** stored by your Web App is ***essential***
for security/privacy.

> If your app offers any personalised content or interaction
that depends on "login", it is storing personal data (_by definition_).
You might be tempted to think that the data is "safe" in the database,
but it's _not_. There is an entire ("dark") army/industry of people
([_cybercriminals_](https://en.wikipedia.org/wiki/Cybercrime))
who target websites/apps attempting to "steal" data.
Don't let the people using your app be the victims of identity theft,
protect their personal data! (_it's both the "**right**" **thing to do** and the **law**_)

## What?

This tutorial/example is intended as a _comprehensive_ answer
to the question:

> ["_**How to Encrypt/Decrypt Sensitive Data** in `Elixir` **Before** Inserting (Saving) it Into the Database?_"](https://github.com/dwyl/learn-elixir/issues/80)

+ We are using the Counter (CTR) Mode Block Cipher for encryption
see: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation
recommended by Niels Ferguson and Bruce Schneier
(_both authorities on security and cryptography_)
+ "Under the hood" we are using Erlang's
[crypto](http://erlang.org/doc/man/crypto.html) module
_specifically_ AES with a 256 bit key (_the same as Google's KMS service_)
see: http://erlang.org/doc/man/crypto.html#stream_init-3

We are _not_ "re-inventing encryption" or using our "own algorithm"
_everyone_ knows that's a "_**bad** idea_":
https://security.stackexchange.com/questions/18197/why-shouldnt-we-roll-our-own
<br />
We are _using_ a _battle-tested_ industry-standard approach
and applying it to our Elixir/Phoenix App.


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

> If you are totally `new` to (_or "rusty" on_) Elixir, Phoenix or Ecto,
we recommend going through our Phoenix Chat Example (Beginner's Tutorial):
https://github.com/dwyl/phoenix-chat-example

You will _not_ need any "Advanced" mathematical knowledge;
we are _not_ "inventing" our own encryption. <br />
We use existing well-tested/respected algorithms.
Specifically:
+ The Advanced Encryption Standard (AES) for _encryption_: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
+ Secure Hash Algorithm (SHA) for hashing data:
https://en.wikipedia.org/wiki/Secure_Hash_Algorithms

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
don't skip any steps.

### 1. Creat the `encryption` App

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

In our _hypothetical_ `user` database table,
we are going to store 3 pieces of data.
+ `name`: the person's name (_encrypted_)
+ `email`: their email address (_encrypted_)
+ `password_hash`: the hashed password (_so they can login_)

In _addition_ to the 3 "_primary_" fields
we need _**two** more fields_:
+ `email_hash`: so we check if an email address is in the database
_without_ having to _decrypt_ the email(s) stored in the DB.
+ `key_id`: the id of the encryption key used to encrypt the data
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
<sup>1</sup>**`key_id`**:
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
3. **Get Key** - get the _latest_ encryption/decryption key.
4. **Hash Email** (_deterministic & **fast**_) - so that we can "lookup" an email
without "decrypting".
The hash of an email address should _always_ be the ***same***.
5. **Hash Password** (_pseudorandom & **slow**_) - the output of the hash
should _always_ be ***different*** and relatively **slow** to compute.


> _**Note**: If you have **any questions** on these functions_,
***please ask***: <br />
[github.com/dwyl/**phoenix-ecto-encryption-example/issues**](https://github.com/nelsonic/phoenix-ecto-encryption-example/issues)


#### 3.1 Encrypt

The `encrypt` function for encrypting `plaintext` Strings
is quite simple; (_only 4 lines_):<br />

```elixir
def encrypt(plaintext) do
  iv    = :crypto.strong_rand_bytes(16) # create random Initialization Vector
  state = :crypto.stream_init(:aes_ctr, get_key(), iv) # create crypto stream
  # peform the encryption:
  {_state, ciphertext} = :crypto.stream_encrypt(state, to_string(plaintext))
  iv <> ciphertext # "return" iv concatenated with the ciphertext
end
```

First we create a "**strong**" random
[***initialization vector***](https://en.wikipedia.org/wiki/Initialization_vector)
(IV) of **128 bits** (***16 bytes***)
using the Erlang's crypto library `strong_rand_bytes` function:
http://erlang.org/doc/man/crypto.html#strong_rand_bytes-1
The "IV" is ensures that each time a string/block of text/data is encrypted,
the `ciphertext`.



#### 3.2 Decrypt

The `decrypt` function _reverses_ the work done by `ecrypt`;
it accepts a "blob" of `ciphertext` (_which as you may recall_),
has the IV prepended to it, and returns the original `plaintext`.

```elixir
def decrypt(ciphertext, key_id) do
  <<iv::binary-16, ciphertext::binary>> = ciphertext # split iv & ciphertext
  # get encryption key based on key_id & Initialise crypto stream:
  state = :crypto.stream_init(:aes_ctr, get_key(key_id), iv)
  # perform decryption
  {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
  plaintext # "return" just the plaintext
end
```

The fist step (line) is to "split" the IV from the `ciphertext`
using Elixir's binary pattern matching.

> If you are unfamiliar with Elixir binary pattern matching syntax
`<<iv::binary-16, ciphertext::binary>>`
read the following guide:
https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html

The `state = :crypto.stream_init(:aes_ctr, get_key(key_id), iv)` line
is the _same_ as in the `encrypt` function,
_except_ that this time we initialise the stream with a _specific_ key
(_the key that was used to `encrypt` the data originally_).

`ciphertext` is decrypted using `stream_decrypt`
http://erlang.org/doc/man/crypto.html#stream_decrypt-2

Finally the original `plaintext` is _returned_.



#### 3.3 Get (Encryption) Key

You will have noticed that _both_ `encrypt` and `decrypt` functions
call a `get_key()` function on the `state = ...` line.
It is not a "built-in" function, we are about to define it!




##### `ENCRYPTION_KEYS` Environment Variable

In order for our `get_key` function to work,
it needs to be know how to "read" the encryption keys.

> _**Note**: we prefer to store our Encryption Keys as
**Environment Variables**

e need to "export" an Environment Variable
containing a (_comma-separated_) list of (_one or more_)
encryption key(s).
_Copy-paste_ (_and run_) the following command into your terminal:

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
+ Is AES-256 weaker than 192 and 128 bit versions?
https://crypto.stackexchange.com/questions/5118/is-aes-256-weaker-than-192-and-128-bit-versions
+ What are the practical differences between 256-bit, 192-bit, and 128-bit AES encryption?
https://crypto.stackexchange.com/questions/20/what-are-the-practical-differences-between-256-bit-192-bit-and-128-bit-aes-enc
+ How to choose an Authenticated Encryption mode
(_by Matthew Green cryptography professor at Johns Hopkins University_):
https://blog.cryptographyengineering.com/2012/05/19/how-to-choose-authenticated-encryption/
+ How to choose an AES encryption mode (CBC ECB CTR OCB CFB)? (v. long answers, but good comparison!)
https://stackoverflow.com/questions/1220751/how-to-choose-an-aes-encryption-mode-cbc-ecb-ctr-ocb-cfb
+ AES GCM vs CTR+HMAC tradeoffs:
https://crypto.stackexchange.com/questions/14747/gcm-vs-ctrhmac-tradeoffs
+ Galois/Counter Mode for symmetric key cryptographic block ciphers: https://en.wikipedia.org/wiki/Galois/Counter_Mode
+ How long (in letters) are encryption keys for AES?
https://security.stackexchange.com/questions/45318/how-long-in-letters-are-encryption-keys-for-aes
+ Generate random alphanumeric string (_used for AES keys_)
https://stackoverflow.com/questions/12788799/how-to-generate-a-random-alphanumeric-string-with-erlang
+ Singular or Plural controller names?: https://stackoverflow.com/questions/35882394/phoenix-controllers-singular-or-plural
+ Postgres Data Type for storing `bcrypt` hashed passwords: https://stackoverflow.com/questions/33944199/bcrypt-and-postgresql-what-data-type-should-be-used >> `bytea` (_byte_)
+ Do security experts recommend bcrypt? https://security.stackexchange.com/questions/4781/do-any-security-experts-recommend-bcrypt-for-password-storage/6415#6415
+ Hacker News discussion thread "***Don't use `bcrypt`***":
https://news.ycombinator.com/item?id=3724560


## Troubleshooting

If _you_ get "stuck", please open an issue describing the issue you are facing.

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
