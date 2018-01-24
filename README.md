# Phoenix Ecto Encryption Example

> All Credit goes to @danielberkompas for his superb post:
http://blog.danielberkompas.com/elixir/security/2015/07/03/encrypting-data-with-ecto.html <br />
> The _reason_ I have created this example is that Daniel's code
is for Phoenix `v0.14.0` ... so needs a _lot_ of updating! <br />
> Note: This is a "commands executed" and "changes made" log.
It is _not_ a "complete beginners' tutorial", sorry ... <br />
If you _need_ a tutorial, please open an issue describing where/how you are "stuck".

Creat a new Phoenix app called "Encryption":
```sh
mix phx.new encryption
```
apparently app names must be lower case:
![lower-case-app-names](https://user-images.githubusercontent.com/194400/35360087-73d69d88-0154-11e8-9f47-d9a9333d1e6c.png)

Works with lowercase:
![second-time-lucky](https://user-images.githubusercontent.com/194400/35360183-c522063c-0154-11e8-994a-7516bc0e5c1e.png)

move files:
```sh
mv encryption/* ./
mv encryption/.gitignore ./
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

> I mirrored much of the functionality in @danielberkompas' original.
> commit ref: 7484d17fbee5cf20825057802a38dac98bd6d3c1
> But now I've reached the point where Phoenix 1.3 diverges ...
> No more "Models" or Ecto callbacks ... need to "update" the code!


Run a _single_ test while debugging:
```sh
mix test test/user/user_test.exs:9
```
