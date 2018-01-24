# Phoenix Ecto Encryption Example

> All Credit goes to @danielberkompas for his superb post:
http://blog.danielberkompas.com/elixir/security/2015/07/03/encrypting-data-with-ecto.html <br />
> The _reason_ I have created this example is that Daniel's code
is for Phoenix `v0.14.0` ... so needs a _lot_ of updating! <br />
> Note: This is a "commands executed" and "changes made" log.
It is _not_ a "complete beginners' tutorial", sorry.
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
