# writeShellApplication supplies Bash and set -euo pipefail.
upgrade=false
case "$#" in
  0) ;;
  1)
    case "$1" in
      --upgrade) upgrade=true ;;
      -h|--help)
        printf '%s\n' \
          'nix-update           — получить конфигурацию, проверить и применить' \
          'nix-update --upgrade — дополнительно обновить flake.lock' \
          'NIRI_CONFIG_DIR      — каталог проекта (по умолчанию ~/niri-clean)' \
          'NIRI_HOST            — профиль flake (по умолчанию vm)'
        exit 0
        ;;
      *) printf 'Неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
    esac
    ;;
  *) printf '%s\n' 'Использование: nix-update [--upgrade]' >&2; exit 2 ;;
esac

config_dir="${NIRI_CONFIG_DIR:-$HOME/niri-clean}"
host="${NIRI_HOST:-vm}"
if [[ ! -f "$config_dir/flake.nix" ]]; then
  printf 'Не найден flake.nix в %s\n' "$config_dir" >&2
  exit 1
fi
cd "$config_dir"
git rev-parse --show-toplevel > /dev/null

printf '%s\n' 'Получение конфигурации из GitHub…'
# No reset, rebase or automatic stash: conflicting local changes remain intact.
git pull --ff-only

if [[ "$upgrade" == true ]]; then
  printf '%s\n' 'Обновление зависимостей в flake.lock…'
  nix flake update
elif [[ ! -f flake.lock ]]; then
  nix flake lock
fi
# A Git-backed flake must include a newly generated lock file.
git add -- flake.lock

printf '%s\n' 'Проверка конфигурации…'
nix flake check
printf '%s\n' 'Сборка системы…'
sudo nixos-rebuild build --flake ".#$host"
printf '%s\n' 'Применение системы…'
sudo nixos-rebuild switch --flake ".#$host"
printf '%s\n' 'Готово. Если обновилось ядро, перезагрузите компьютер.'
