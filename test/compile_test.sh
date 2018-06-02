. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

PRINCE_TARBALL_URL='https://www.princexml.com/download/prince-11.4-linux-generic-x86_64.tar.gz'

assertExitCode() {
  assertTrue "Expected captured exit code to be <${1}>; was <${RETURN}>" "[ ${RETURN} -eq ${1} ]"
}

test_missing_prince_tarball_environment_variable() {
  compile

  assertExitCode 1
  assertCaptured "Environment variable PRINCE_TARBALL was not set"
}

test_missing_prince_tarball_url() {
  echo 'http://example.com/prince-3.141592653-non-existent-tarball-x64.tgz' > $ENV_DIR/PRINCE_TARBALL

  compile

  assertExitCode 1
  assertCaptured "Installing Prince 3.141592653"
  assertCaptured "Could not download Prince"
}

test_prince_tarball_not_downloaded() {
  echo "$PRINCE_TARBALL_URL" > $ENV_DIR/PRINCE_TARBALL

  compile

  assertExitCode 0
  assertCaptured "Installing Prince 11.4"
  assertCaptured "Unpacking Prince tarball..."
  assertCaptured "Unpacked."
  assertCaptured "Configuring license file..."
  assertCaptured "Skipped."
  assertCaptured "Running Prince installer..."
  assertCaptured "Installation complete."
}

test_invalid_tarball() {
  echo "$PRINCE_TARBALL_URL" > $ENV_DIR/PRINCE_TARBALL
  cp $BUILDPACK_HOME/test/invalid.tgz $CACHE_DIR/prince-11.4-linux-generic-x86_64.tar.gz

  compile

  assertExitCode 1
  assertCaptured "Installing Prince 11.4"
  assertCaptured "Unpacking Prince tarball..."
  assertCaptured "Error unpacking downloaded tarball"
}

test_non_prince_tarball() {
  echo "$PRINCE_TARBALL_URL" > $ENV_DIR/PRINCE_TARBALL
  cp $BUILDPACK_HOME/test/not-prince.tgz $CACHE_DIR/prince-11.4-linux-generic-x86_64.tar.gz

  compile

  assertExitCode 1
  assertCaptured "Installing Prince 11.4"
  assertCaptured "Unpacking Prince tarball..."
  assertCaptured "Unpacked tarball did not contain an install.sh script"
}

test_prince_successfully_installed_with_license() {
  echo "$PRINCE_TARBALL_URL" > $ENV_DIR/PRINCE_TARBALL
  echo "LICENSE DATA" > $ENV_DIR/PRINCE_LICENSE
  cp $BUILDPACK_HOME/test/prince.tgz $CACHE_DIR/prince-11.4-linux-generic-x86_64.tar.gz

  compile

  assertExitCode 0
  assertCaptured "Installing Prince 11.4"
  assertCaptured "Unpacking Prince tarball..."
  assertCaptured "Unpacked."
  assertCaptured "Configuring license file..."
  assertCaptured "Configured."
  assertCaptured "Running Prince installer..."
  assertCaptured "Installation complete."
}

test_prince_successfully_installed_without_license() {
  echo "$PRINCE_TARBALL_URL" > $ENV_DIR/PRINCE_TARBALL
  cp $BUILDPACK_HOME/test/prince.tgz $CACHE_DIR/prince-11.4-linux-generic-x86_64.tar.gz

  compile

  assertExitCode 0
  assertCaptured "Installing Prince 11.4"
  assertCaptured "Unpacking Prince tarball..."
  assertCaptured "Unpacked."
  assertCaptured "Configuring license file..."
  assertCaptured "Skipped."
  assertCaptured "Running Prince installer..."
  assertCaptured "Installation complete."
}
