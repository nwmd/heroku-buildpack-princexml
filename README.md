# Heroku Buildpack PrinceXML

A buildpack that installs PrinceXML on Heroku.

## Configuration

**PRINCE_TARBALL** (Required)

The URL of the Prince tarball to download and install.

**PRINCE_LICENSE**

The XML license data for your Prince license.  If absent, Prince will run in a
trial mode that watermarks all generated PDFs.

## Testing

This buildpack comes with automated tests.  These live in `test`, and can be run
locally in Docker with the following command:

    docker run -it -v `pwd`:/app/buildpack:ro heroku/buildpack-testrunner
