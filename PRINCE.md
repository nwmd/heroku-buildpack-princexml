# Prince's Install Script

The Prince install script (fairly simple as of version 11.4) is worth spending
some time to understand if you are interested in working on this Buildpack.
Fortunately, it's not very long – the entirety is included at the end of this
document.

## Script Highlights

* The script inputs the target installation directory using `read -r`.  This
  allows us to supply input on `STDIN`.
* The script creates and installs a binstub that hardcodes the installation
  directory.  **This is the single biggest challenge for this Buildpack.**
  * Buildpacks are expected to create code that is relocatable.  If we install
    to `$BUILD_DIR`, the binstub will point to a non-existent location in the
    runtime environment.  If we "outsmart" the system and install it to where
    the application is supposed to _eventually_ reside, the results may be
    unpredictable.
  * Solutions available include:
    * Creating a new binstub (e.g. in `$BUILD_DIR/bin`) with the correct runtime
      paths.
    * Replacing the generated binstub with corrected runtime paths.
    * Replacing the generated binstub with a relocatable binstub.
* The script uses `install` to create the target directories and copy all files.

## Prince's `install.sh`

``` sh
#! /bin/sh

PRODUCT="Prince"
PROGRAM="prince"
VERSION="11.4"
WEBSITE="http://www.princexml.com"

prefix=/usr/local

base=$( dirname "$0" )

cd "$base" || exit 1

echo "$PRODUCT $VERSION"
echo
echo "Install directory"
echo "    This is the directory in which $PRODUCT $VERSION will be installed."
echo "    Press Enter to accept the default directory or enter an alternative."
printf "    [%s]: " "$prefix"

IFS= read -r input
if [ ! -z "$input" ] ; then
    prefix="$input"
fi

echo
echo "Installing $PRODUCT $VERSION..."

# Create shell script

cat > prince <<EOF
#! /bin/sh

exec "$prefix/lib/$PROGRAM/bin/$PROGRAM" --prefix="$prefix/lib/$PROGRAM" "\$@"
EOF

# Test that we can create directories

install -d "$prefix/bin" 2>/dev/null ||
{
echo "    Unable to create directories in $prefix"
echo "    (You may need to be logged in as root to install programs in system"
echo "    directories. Ask your system administrator, or try installing inside"
echo "    your home directory, such as $HOME/$PROGRAM-$VERSION)."
echo
exit 1
}

# Install shell script

install prince "$prefix/bin" || exit 1

# Install everything else

echo "Creating directories..."

for dir in $( find "lib/$PROGRAM" -type d ) ; do

    install -d "$prefix/$dir" || exit 1

done

echo "Installing files..."

for file in $( find "lib/$PROGRAM" -type f ) ; do

    dir=$( dirname "$file" )

    if [ -x "$file" ] ; then
	install "$file" "$prefix/$dir" || exit 1
    else
	if [ "$file" = "lib/$PROGRAM/license/license.dat" ] ; then
	    if [ ! -f "$prefix/$file" ] ; then
		install -m 644 "$file" "$prefix/$dir" || exit 1
	    fi
	else
	    install -m 644 "$file" "$prefix/$dir" || exit 1
	fi
    fi

done

echo
echo "Installation complete."
echo "    Thank you for choosing $PRODUCT $VERSION, we hope you find it useful."
echo "    Please visit $WEBSITE for updates and development news."
echo
```
