# Heroku Buildpacks

## Getting Started

As a jumping off point, you can always dive in to the most current documentation
from [Heroku](https://devcenter.heroku.com/articles/buildpack-api#buildpack-api).
If you're looking for a summary, read on.

## Buildpack Design

Buildpacks were designed around a few key features.

* **Atomic** – Buildpacks either apply successfully, or they have no effect on
  the final application bundle.
* **Machine Agnostic** – Buildpacks are always built in an environment matching
  the application's stack.  That build environment, however, may or may not be
  the same machine the application will run on, or even the same machine other
  Buildpacks are built on.
* **Repeatability** – At Heroku's scale, it doesn't pay to have "snowflake"
  machines.  Applying the same Buildpacks in the same order **must** yield the
  same results, every time.

## Basic API

The Buildpack API is comprised of three scripts.

* `bin/detect <BUILD_DIR>`
  * Test the application for compatibility with this Buildpack.
  * (e.g.) Test for a `package.json` before installing the Node Buildpack.
* `bin/compile <BUILD_DIR> <CACHE_DIR> <ENV_DIR>`
  * Apply the Buildpack to the application.
  * (e.g.) Install Node, npm, and all of the application's dependencies.
* `bin/release <BUILD_DIR>`
  * Update the application, if necessary.
  * (e.g.) Provide a default script for `web` nodes.

Any script with a non-zero exit code causes the Buildpack to abort.

## High-Level Process

Premise: Application `A` is configured with a Buildpack, `B`.

* The repository for `B` is cloned into a temporary directory.
* The code for `A` is copied into another temporary directory.  (Let's call it
  `/tmp/application`.)
* For each Buildpack:
  * `/tmp/application` is copied into a temporary directory specific to this
    *build* (`$BUILD_DIR`).
  * The configured environment variables for `A` are written into another
    temporary directory, specific to this *build* (`$ENV_DIR`).
  * A directory name is reserved for this specific *Buildpack* to use for
    caching (`$CACHE_DIR`).
  * The Buildpack determines whether it applies to this application.
    * `$ bin/detect $BUILD_DIR`
    * If the script exits non-zero, we move on to the next Buildpack.
  * The Buildpack "installs itself" into this application.
    * `$ bin/compile $BUILD_DIR $CACHE_DIR $ENV_DIR`
    * If the script exits non-zero, we move on to the next Buildpack.
  * The Buildpack reports application configuration changes.
    * `$ bin/release $BUILD_DIR`
    * If the script exits non-zero, we move on to the next Buildpack.
  * Application configuration changes are noted, and the contents of
    `$BUILD_DIR` are copied back to `/tmp/application`.
* After all Buildpacks have been processed, the contents of `/tmp/application`
  are bundled up, and shipped to the production server, where they will be
  unpacked into `$HOME`.

## `/bin/compile`

The `compile` script is clearly the heart of a Buildpack, so it's worth looking
at more closely.  There are three explicit arguments, which all refer to
directories.

### `BUILD_DIR`
This is a temporary directory containing the application + any previous
Buildpack modifications.  This is **not** the application directory, but any
changes you make in this directory will be reflected in the compiled application
bundle.

### `CACHE_DIR`
This path may be used across multiple application builds to store expensive or
intermediate build products.

### `ENV_DIR`
For build cleanliness, the application's environment variables are not exported
into the build environment, but are exposed as files in `ENV_DIR`.

There are two other directories that are commonly of interest:

### `$(cd $(dirname ${0:-}); cd ..; pwd)` a.k.a. `BP_DIR`
This is the root directory for the Buildpack itself, which may be useful if your
Buildpack bundles static assets, or needs to source helper libraries.

### `$HOME`
While you should avoid using this in the *build environment*, the `$HOME`
directory in the *runtime environment* is the directory the application is
copied into after all of the Buildpacks have been applied.  This is particularly
relevant for any scripts or binstubs you may write – if your *runtime* script
relies on something you wrote into `BUILD_DIR`, it will find it in `$HOME`.
