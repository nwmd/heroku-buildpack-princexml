# Heroku Buildpack PrinceXML

A buildpack that installs PrinceXML on Heroku.

To use a Prince license, remove all carriage returns from the Prince license.dat XML file and copy/paste the string into a Heroku environment variable named PRINCE_LICENSE. Note that the buildpack itself generates the license file from the ENV variable, so you will need to re-deploy your app to generate it.
