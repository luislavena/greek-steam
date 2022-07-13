# Greek Steam
> Production-ready PHP container image based on Debian, tailored for Laravel Vapor & Twill CMS

## Features

* Use Debian stable as base for environment parity (following [Twelve-Factor App][twelve-factor-app])
* Use Docker's official PHP images with minor customizations
* Be slim as much as possible
* Be frequently updated using GitHub Actions

This project does **not** aim to:

* Be used for development (see [hydrofoil-php][hydrofoil-php] instead)
* Be compatible with environments other than [Laravel Vapor][laravel-vapor] (may or may not work)
* Be _everything but the kitchen sink_

## Overview

This project aims to be used **in production**, as the configuration settings
have been tweaked specifically for that purpose and for Laravel Vapor.

Tested and tuned to work with [Twill CMS][twill-cms], leaving to you to bring
only your application packages and be able to deploy seamless from your
console with `vapor deploy` or your CI environment.

Please note that this image does not contain any development tools like
Composer, NodeJS or Yarn, as those should be used _before_ to generate the
needed artifacts that will be integrated within the final image.

## Requirements

You will need a working installation of [Docker][docker] on your machine or
the CI environment used when `vapor deploy` is invoked.

## Usage

Update your `vapor.yml` configuration file indicating to use Docker runtime,
like this example:

```diff
 name: vapor-laravel-app
 environments:
   production:
-    runtime: 'php-8.0:al2'
+    runtime: docker
     build:
       - 'composer install --no-dev'
```

Next, create a Dockerfile for that environment, following Vapor's conventions
and naming the file `production.Dockerfile`:

```dockerfile
FROM ghcr.io/luislavena/greek-steam:8.0

# Place application in Lambda application directory...
COPY . /var/task
```

With that in place, your next `vapor deploy` for that environment will use
this configuration and deploy based on the new runtime selected.

Refer to Laravel Vapor's own documentation about
[Docker runtimes][vapor-docker-runtime] for details on using Docker and a
local `Dockerfile`.

## Contribution Policy

This project is open to code contributions for bug fixes only. Features carry
a long-term maintenance burden so they will not be accepted at this time.
Please [submit an issue][new-issue] if you have a feature you'd like to
request or discuss.

[twelve-factor-app]: https://12factor.net/dev-prod-parity
[hydrofoil-php]: https://github.com/luislavena/hydrofoil-php
[laravel-vapor]: https://vapor.laravel.com
[twill-cms]: https://twill.io
[new-issue]: https://github.com/luislavena/greek-steam/issues/new
[docker]: https://docs.docker.com/get-docker/
[vapor-docker-runtime]: https://docs.vapor.build/1.0/projects/environments.html#runtime
