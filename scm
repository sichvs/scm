PKGDIR="$PREFIX/var/pkgs"
LIST="$PREFIX/var/scm/list.txt"
CACHE="$PREFIX/var/scm/cache"
CMD="$1"
PKG="$2"

mkdir -p "$PKGDIR"
mkdir -p "$(dirname "$LIST")"
touch "$LIST"

if ! command -v gum >/dev/null 2>&1; then
  echo "Installing gum..."
  pkg install gum -y >/dev/null 2>&1
fi

case "$CMD" in
  i)
    if [ -z "$PKG" ]; then
      echo "Usage: scm i <package>"
      exit 1
    fi

    PKGPATH="$PKGDIR/$PKG"
    BUILDSCRIPT="$PKGPATH/build.bash"

    if [ ! -d "$PKGPATH" ]; then
      echo "Error: package '$PKG' not found in $PKGDIR"
      exit 1
    fi

    if [ ! -f "$BUILDSCRIPT" ]; then
      echo "Error: build.bash not found in $PKGPATH"
      exit 1
    fi

    gum spin --spinner dot --title "Installing $PKG..." -- bash "$BUILDSCRIPT"

    if ! grep -qx "$PKG" "$LIST"; then
      echo "$PKG" >> "$LIST"
    fi

    echo "Package '$PKG' installed successfully."
    ;;

  rv)
    if [ -z "$PKG" ]; then
      echo "Usage: scm rv <package>"
      exit 1
    fi

    if ! grep -qx "$PKG" "$LIST"; then
      echo "Error: package '$PKG' is not installed."
      exit 1
    fi

    gum spin --spinner dot --title "Removing $PKG..." -- sleep 16

    sed -i "/^$PKG$/d" "$LIST"
    echo "Package '$PKG' removed successfully."
    ;;

  list)
    echo "Installed packages:"
    if [ ! -s "$LIST" ]; then
      echo "(none)"
    else
      cat "$LIST"
    fi
    ;;

  repo)
    echo "Available packages:"
    if [ "$(ls "$PKGDIR")" ]; then
      ls "$PKGDIR"
    else
      echo "(empty)"
    fi
    ;;


  update)
    echo "Cleaning cache and temporary files..."
    rm -rf "$CACHE"
    rm -rf "$HOME/.cache" 2>/dev/null
    echo "Cleanup complete."
    ;;

  *)
    echo "Usage: scm <command> [package]"
    echo ""
    echo "Available commands:"
    echo "  i <package>   - Install a package"
    echo "  rv <package>  - Remove a package"
    echo "  list          - List installed packages"
    echo "  repo          - Show available packages in local repo"
    echo "  update        - Clear cache and temporary files"
    ;;
esac
