This is a docker image of the [php dependency manager tool composer](https://getcomposer.org/).

We dockerized composer so that our continuous integration servers would not need to know anything about composer.

The nice part of this implementation is that you can dynamically set the user and group id of the user that will run composer, so that you don't run in permission issues when downloading dependencies.

Our implementation makes use of the excellent [gosu](https://github.com/tianon/gosu).

Usage examples
--------------
### Simple `composer install` usage with some explanations
Most of the time, the following command will suffice to install your php dependencies.
```bash
$ docker run \
  -v $(pwd):/app \
  -v $HOME/.composer:/home/composer \
  rayrutjes/composer
```
Under the hood, this will call `composer install`, and download all the files on the mounted volume `$(pwd)`.

We also mounted an optional second volume `$HOME/.composer:/home/composer`. This volume allows you to map your local composer home folder to the container's one so that you can benefit from the native caching mechanism.

Mounting the composer home directory makes even more sense when done on the continuous integration servers, as you will get much quicker feedback from your tests on your {merge|pull}requests.

Mounting that directory also allows you to re-use your access keys for github authentication.

### Production usage
When you are setting up your project for production, you can simply override the default container arguments.
All the arguments are proxied to the actual composer script.
```bash
$ docker run \
  -v $(pwd):/app \
  -v $HOME/.composer:/home/composer \
  rayrutjes/composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader
```

### Run the composer container as your very own user and group
Most of the composer images around that we have tried did not give us a way to choose the user and group composer is executed as. This resulted for us with the inability to use a same docker composer image for our local developments on linux, mac and our continuous integration servers.

Let's say you are working locally on a project, and `$(id -u):$(id -g)` tells you your are `1005:1005`.

If you were to run the container without changing the user and group ids, then the files downloaded by composer would be attributed to the user `1000:1000` by default which might cause you some trouble.

You can instead simply do the following to run composer as `1005:1005`:
```bash
$ docker run \
  -v $(pwd):/app \
  -v $HOME/.composer:/home/composer \
  -e "USER_ID=1005" \
  -e "GROUP_ID=1005" \
  rayrutjes/composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader
```
Or if you want to make it a bit more context aware:
```bash
$ docker run \
  -v $(pwd):/app \
  -v $HOME/.composer:/home/composer \
  -e "USER_ID=$(id -u)" \
  -e "GROUP_ID=$(id -g)" \
  rayrutjes/composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader
```
**If you are using boot2docker or if you are the lucky `1000:1000` user, then the default configuration will work out just fine for you!**

### Other composer commands
As this image is just a wrapper around the official composer script, you can pass all the other available arguments that are well documented on [the official website](https://getcomposer.org/).

Contribution
------------
Please feel free to share your opinion, ask your questions or contribute in any other form.

Special thanks goes to [@wysow](https://github.com/wysow) for having insisted on the fact that there was definitely a better way to implement a composer image.
