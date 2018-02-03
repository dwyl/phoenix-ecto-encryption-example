<!-- # Phoenix Ecto Encryption Example -->

## Why?

**Encrypting User/Personal data** stored by your Web App is ***essential***
for security/privacy.

>


## What?

This tutorial/example is intended as a _comprehensive_ answer
to the question:

> ["_**How to Encrypt/Decrypt Sensitive Data** in **Elixir** Before Inserting it Into the Database?_"](https://github.com/dwyl/learn-elixir/issues/80)




## Who?

Any developer (_or technical decision maker / "application architect"_)
who takes personal data protection seriously
and wants a robust way of encrypting data `before` storing it.


## How?


Creat a new Phoenix app called "Encryption":
```sh
mix phx.new encryption
```

> Since I created the new phoenix app inside an existing git directory, <br />
  I had to move the files into the "current working directory"
  move files:
  ```sh
  mv encryption/* ./
  mv encryption/.gitignore ./
  ```
  If you are creating the project from scratch without a git repo, <br />
  you can skip this step. <br />
  _Instead_ simply **change** into the `encryption` directory: <br />
  ```sh
  cd encryption
  ```


Create the database:
```sh
mix ecto.create
```

![mix-ecto-create](https://user-images.githubusercontent.com/194400/35360428-914eb84a-0155-11e8-8395-1e352223f509.png)


Create the `user` schema using generator command:
```
mix phx.gen.schema User users name:binary email:binary email_hash:binary
```

![phx.gen.schema](https://user-images.githubusercontent.com/194400/35360796-dc4507cc-0156-11e8-9cf1-7f4005e5ed34.png)


Create the tables in the DB:
```sh
mix ecto.migrate
```





<br />

## Credits

_All_ Credit for this example goes to [@danielberkompas](https://github.com/danielberkompas) for his _superb_ post:
http://blog.danielberkompas.com/elixir/security/2015/07/03/encrypting-data-with-ecto.html <br />

Daniel's post is for [Phoenix `v0.14.0`](https://github.com/danielberkompas/danielberkompas.github.io/blob/c6eb249e5019e782e891bfeb591bc75f084fd97c/_posts/2015-07-03-encrypting-data-with-ecto.md) which is quite "old" now ...
therefore a few changes/updates are required.
e.g: There are no more "**Models**" in Phoenix 1.3 or Ecto callbacks.

_Also_ his post only includes the "sample code" and is not a _complete_ example.
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

<br />

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
