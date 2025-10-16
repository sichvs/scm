repo="$HOME/scm^3/repo"
pkgdir="$repo/packages"
list="$repo/list.txt"

cmd="$1"
pkg="$2"

mkdir -p "$pkgdir"
touch "$list"

install_pkg() {
  local pkg="$1"
  if [ -z "$pkg" ]; then
    echo "Error: package name required."
    exit 1
  fi
  if grep -qx "$pkg" "$list"; then
    echo "Package '$pkg' is already installed."
    exit 1
  fi
  if [ ! -d "$pkgdir/$pkg" ]; then
    echo "Package '$pkg' not found in repository."
    exit 1
  fi
  local script="$pkgdir/$pkg/$pkg.bash"
  if [ ! -f "$script" ]; then
    echo "Install script missing for '$pkg'."
    exit 1
  fi
  bash "$script" || { echo "Installation failed for '$pkg'."; exit 1; }
  echo "$pkg" >> "$list"
  echo "Installed '$pkg' successfully."
}

uninstall_pkg() {
  local p="$1"
  [ -n "$p" ] || { echo "Error: package name required."; exit 1; }

  if ! grep -Fxq "$p" "$list"; then
    echo "Package '$p' is not installed."
    exit 1
  fi

  local d="$pkgdir/$p"
  local removed_any=false

  # Executa o script de desinstalação, se existir
  if [ -d "$d" ] && [ -x "$d/uninstall.bash" ]; then
    ( bash "$d/uninstall.bash" ) || echo "Warning: uninstall script failed for '$p'" >&2
  fi

  # Remove arquivos e diretórios relacionados
  for loc in "$PREFIX/bin/$p" "$PREFIX/bin/.$p" "$HOME/$p" "$HOME/.$p"; do
    if [ -e "$loc" ]; then
      rm -rf "$loc"
      echo "Removed: $loc"
      removed_any=true
    fi
  done

  # Atualiza list.txt ou pergunta
  if [ "$removed_any" = true ]; then
    sed -i "/^${p}$/d" "$list"
    echo "Uninstalled '$p' successfully."
  else
    echo "No files found for '$p'."
    read -p "Do you want to remove '$p' from list.txt anyway? [y/N]: " confirm
    case "$confirm" in
      [yY]|[yY][eE][sS])
        sed -i "/^${p}$/d" "$list"
        echo "'$p' removed from list.txt."
        ;;
      *)
        echo "'$p' kept in list.txt."
        ;;
    esac
  fi
}

list_pkgs() {
  echo "Installed packages:"
  if [ -s "$list" ]; then
    cat "$list"
  else
    echo "(none)"
  fi
}

case "$cmd" in
  i) install_pkg "$pkg" ;;
  un) uninstall_pkg "$pkg" ;;
  list) list_pkgs ;;
  *)
    echo "Usage:"
    echo "  smc i <package>    Install a package"
    echo "  smc un <package>   Uninstall a package"
    echo "  smc list           List installed packages"
    ;;
esac
