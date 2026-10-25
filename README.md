# NixOS + Niri — тестовая QEMU/KVM VM

Адаптация [JotaFab/s13los](https://github.com/JotaFab/s13los), происхождение — [UPSTREAM.md](UPSTREAM.md).

Профиль: `niri-vm`; пользователь: `nikolaev`; NixOS 26.05; UEFI/systemd-boot.
Сохранены UUID и структура Btrfs существующей ВМ, без форматирования.
Пароль существующего пользователя сохраняется; автоматический вход не включён.
Home Manager впервые настраивается с stateVersion 26.05.

Рабочий стол: Niri, Waybar, Wofi, Ghostty, Firefox, Nautilus, уведомления,
PipeWire, блокировка swaylock. EN/RU: Alt+Shift. Тёмная тема, чёрный фон панели.
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
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git
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

Первое `nix shell` открывает вложенную оболочку с Git; продолжайте команды в ней.
Требуется интернет до GitHub и кеша NixOS. Первый flake lock фиксирует версии —
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
| Super+D | Меню приложений |
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

`nix flake check` проверяет синтаксис Niri и JSON панели, а также вычисление NixOS.
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
