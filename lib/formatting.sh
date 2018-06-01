indent() {
  sed -u 's/^/       /'
}

info() {
  echo "       $*"
}

error() {
  echo " !     $*"
}

topic() {
  echo "-----> $*"
}
