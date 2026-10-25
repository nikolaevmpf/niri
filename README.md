# NixOS + Niri + Noctalia — тестовая QEMU/KVM VM

Адаптация [JotaFab/s13los](https://github.com/JotaFab/s13los), происхождение — [UPSTREAM.md](UPSTREAM.md).

Профиль: `niri-vm`; пользователь: `nikolaev`; NixOS 26.05; UEFI/systemd-boot.
Сохранены UUID и структура Btrfs существующей ВМ, без форматирования.
Пароль существующего пользователя сохраняется; автоматический вход не включён.
Home Manager впервые настраивается с stateVersion 26.05.

Рабочий стол: Niri + Noctalia v5, Ghostty, Firefox, Nautilus,
PipeWire, блокировка swaylock. EN/RU: Alt+Shift. Тёмная тема Catppuccin.
Noctalia заменяет Waybar, Wofi и SwayNC: панель, меню приложений и уведомления.
Графика Mesa без принудительного NVIDIA-драйвера.
QEMU guest agent и SPICE agent работают при наличии соответствующих каналов ВМ.

## Перед применением

Сделайте снимок выключенной ВМ средствами гипервизора.
Для Niri рекомендуется Virtio video с 3D acceleration и SPICE/OpenGL,
если хост и клиент поддерживают этот режим. Пока фактическая видеокарта не проверена,
запуск графической сессии не гарантирован. Не меняйте настройки работающей ВМ.

Проверьте модель внутри ВМ: `lspci -nnk | rg -A3 -i 'vga|display|3d'`.
Если rg отсутствует, выполните просто `lspci -nnk`.
Без SPICE-канала гостевой агент SPICE не обеспечит обмен буфером.

## Установка на существующую ВМ

Команды выполняются под пользователем nikolaev, по одной строке:

```bash
sudo cp -a /etc/nixos "/etc/nixos.before-niri-$(date +%Y%m%d-%H%M%S)"
nix-shell -p git
git clone https://github.com/nikolaevmpf/niri.git ~/niri
cd ~/niri
cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
git add hardware-configuration.nix
nix --extra-experimental-features "nix-command flakes" flake lock
git add flake.lock
nix --extra-experimental-features "nix-command flakes" flake check
sudo nixos-rebuild build --flake .#niri-vm
sudo nixos-rebuild boot --flake .#niri-vm
sudo reboot
```

Первое `nix-shell` открывает вложенную оболочку с Git; продолжайте команды в ней.
Требуется интернет до GitHub, channels.nixos.org, кеша NixOS и noctalia.cachix.org. Первый flake lock фиксирует версии —
сохраните его коммитом в репозитории после успешной проверки.
В опубликованном проекте lock пока нет: среда подготовки не содержит Nix.
Обновлять зависимости без необходимости не нужно.

В Ly выберите сессию Niri и войдите с существующим паролем.
Профиль применяется из ~/niri; /etc/nixos остаётся резервной конфигурацией,
обычный rebuild без --flake использует её.

## Клавиши

Mod — клавиша Super/Windows. Если комбинации перехватывает хост,
включите захват клавиатуры в просмотрщике ВМ.

| Клавиши | Действие |
|---|---|
| Super+T | Ghostty |
| Super+B | Firefox |
| Super+E | Файлы |
| Super+D | Меню приложений Noctalia |
| Super+S | Центр управления Noctalia |
| Super+Shift+S | Настройки Noctalia |
| Super+Shift+X | Меню выхода / перезагрузки |
| Super+W | Показать / скрыть панель |
| Super+Q | Закрыть окно |
| Super+стрелки | Перемещение фокуса |
| Super+Ctrl+стрелки | Перемещение окон/колонок |
| Super+PageUp/PageDown | Рабочие пространства |
| Super+F / Super+Shift+F | Развернуть колонку / полный экран |
| Super+V | Плавающее окно |
| Super+Shift+L | Блокировка |
| Super+Shift+E | Выход с подтверждением |
| Super+Shift+/ | Подсказка клавиш |
| Alt+Shift | EN/RU |
| Print | Снимок экрана |

## Проверка и диагностика

`nix flake check` проверяет синтаксис Niri, а также вычисление NixOS.
`nixos-rebuild build` собирает всю систему, но не подтверждает работу GPU в ВМ.
В среде подготовки доступна только статическая проверка файлов — полная сборка и
проверка входа в сессию должны быть выполнены на ВМ.

```bash
niri validate
niri msg outputs
systemctl --user status niri
journalctl --user -b -u niri --no-pager
systemctl status ly --no-pager
wpctl status
```

Если графика не запускается: перейдите в TTY (Ctrl+Alt+F3, при необходимости через
меню отправки клавиш просмотрщика), войдите и получите `lspci -nnk` и журнал Niri.
Для проверки Virtio/3D на хосте нужны параметры Video и Display.

## Изменения и откат

После правок:

```bash
cd ~/niri
nix flake check
sudo nixos-rebuild build --flake .#niri-vm
sudo nixos-rebuild boot --flake .#niri-vm
sudo reboot
```

При неудачной загрузке выберите предыдущую генерацию NixOS в меню systemd-boot
(при запуске удерживайте Space). Команда отката из TTY:

```bash
sudo nixos-rebuild switch --rollback
```

Home Manager создаёт резервные копии конфликтующих файлов с суффиксом
`.before-niri`. Если такая копия уже существует, переместите её в безопасное место,
прежде чем повторять активацию. Для возврата пользовательских настроек при
необходимости восстановите эти копии вручную.

## Noctalia

Используется актуальная Noctalia v5 из официального репозитория noctalia-dev/noctalia,
коммит 40a82f21ab5f135f4324b1862f7b7732af581856 (из ветки cachix).
Это текущая версия проекта, ранее известного как Noctalia Shell; v4 на Quickshell —
отдельная legacy-ветка. Команды v4 `qs -c noctalia-shell` здесь не используются.

У Noctalia отдельный upstream nixpkgs unstable, основная NixOS остаётся 26.05.
Кеш добавлен с официальным публичным ключом. При первом применении кеш ещё может
быть не активен в старой системе, поэтому возможна сборка Noctalia из исходников.

Настройки по умолчанию: modules/home/programs/noctalia.nix.
Home Manager генерирует ~/.config/noctalia/config.toml с проверкой конфигурации при сборке.
Изменения через интерфейс сохраняются отдельно в ~/.local/state/noctalia/settings.toml
и могут перекрывать значения из Nix. Автозапуск выполняет только Niri.

Блокировка Noctalia отключена: Super+Shift+L по-прежнему запускает swaylock.
Polkit обслуживает существующий GNOME agent.
В ВМ нет физических Wi-Fi/Bluetooth-устройств и батареи; соответствующие функции
не появятся от одной установки оболочки. NetworkManager и UPower включены.

Обновление уже клонированного проекта (сохраните любые собственные правки коммитом
перед git pull; локальный flake.lock обычно не мешает, поскольку на сервере его нет):

```bash
cd ~/niri
git pull --ff-only
nix --extra-experimental-features "nix-command flakes" flake lock
git add flake.lock
nix --extra-experimental-features "nix-command flakes" flake check
sudo nixos-rebuild build --flake .#niri-vm
sudo nixos-rebuild boot --flake .#niri-vm
sudo reboot
```

Диагностика в работающей сессии:

```bash
noctalia msg status
noctalia msg settings-open
tail -n 100 ~/.cache/noctalia/noctalia.log
```

Если Noctalia не стартовала, откройте Ghostty (Super+T) и выполните `noctalia`,
чтобы увидеть ошибку. Для обновления закреплённой версии измените URL в flake.nix
на нужный коммит; затем выполните flake lock и проверки.

Официальные инструкции:
https://docs.noctalia.dev/noctalia/getting-started/nixos/
https://docs.noctalia.dev/noctalia/compositor-settings/niri/
