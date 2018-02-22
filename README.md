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

You do _not_ need to _understand_ the how either of the algorithms work, <br />
merely to know the _difference_ between
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
When you see `Fetch and install dependencies? [Yn]`, type `y` and press the `[Enter]` key
to download and install the dependencies.
You should see:

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
Follow the first two instruction to **change** into the `encryption` directory: <br />
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
we are only going to store 3 pieces of data.
+ `name`: the person's name (_encrypted_)
+ `email`: their email address (_encrypted_)
+ `password_hash`: the hashed password (_so they can login_)

**Note**: in _addition_ to these 3 "_primary_" fields
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


The _reason_ we are creating the fields as `:binary`
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
of data an "attacker" can get when compromising_
</small>


### 3. Define The 4 Functions





<br /> <br />

## Credits

Credit for this example goes to [@danielberkompas](https://github.com/danielberkompas)
for his post:
https://blog.danielberkompas.com/2015/07/03/encrypting-data-with-ecto<br />

Daniel's post is for [Phoenix `v0.14.0`](https://github.com/danielberkompas/danielberkompas.github.io/blob/c6eb249e5019e782e891bfeb591bc75f084fd97c/_posts/2015-07-03-encrypting-data-with-ecto.md) which is quite "old" now ...
therefore a few changes/updates are required.
e.g: There are no more "**Models**" in Phoenix 1.3 or Ecto callbacks.

_Also_ his post only includes the "sample code"
and is _not_ a _complete_ example. <br />
Which means anyone following the post needs to _manually_ copy-paste the code...
We prefer to include the _complete_ "end state" of any tutorial so that
people can `git clone` and _`run`_ the code locally.

I reached out to Daniel on Twitter
asking if he would accept a Pull Request
updating the post to latest version of Phoenix: <br />
[![credit-tweet](https://user-images.githubusercontent.com/194400/35771850-32b1cfba-092b-11e8-9bbf-0e693016bb76.png)](https://twitter.com/nelsonic/status/959901100760498181) <br />
If he replies I will _gladly_ create a PR.
_Meanwhile_ this example will fill in the gaps
and provide a more up-to-date example.

<br /> <br />

## Troubleshooting

If you get "stuck", please open an issue describing the issue you are facing.

TIL: app names in Phoneix _must_ be lowercase letters: <br />
![lower-case-app-names](https://user-images.githubusercontent.com/194400/35360087-73d69d88-0154-11e8-9f47-d9a9333d1e6c.png)

Works with lowercase:  <br />
![second-time-lucky](https://user-images.githubusercontent.com/194400/35360183-c522063c-0154-11e8-994a-7516bc0e5c1e.png)

### Running a Single Test

To run a _single_ test while debugging, use the following syntax:
```sh
mix test test/user/user_test.exs:9
```
