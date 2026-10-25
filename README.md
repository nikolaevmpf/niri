# NixOS + Niri: минимальная модульная конфигурация

Начинаем с чистой основы. Активный профиль: **vm**, имя компьютера: **niri-vm**,
пользователь: **nikolaev**, NixOS **26.05**, архитектура **x86_64-linux**.

Первый этап: Niri (Wayland-композитор), PipeWire + WirePlumber, терминал Ghostty,
минимальный экран входа greetd/tuigreet, браузер Firefox. Сразу после входа запускается Ghostty.
Установлены Git, Nano и pciutils для обслуживания конфигурации.
Wayland и порталы настраивает штатный модуль NixOS `programs.niri`.
Xorg-сессия не включена.

На этом этапе нет оболочки рабочего стола, панели, меню приложений, уведомлений
и файлового менеджера. Это ожидаемый минимальный рабочий стол.
Noctalia, старые модули и настройки исходного проекта удалены из текущего дерева.
Предыдущие версии доступны в истории Git.

## Структура

| Путь | Назначение |
|---|---|
| flake.nix | Зависимости и профиль vm |
| hosts/vm/default.nix | Состав профиля и версия начальной установки |
| hosts/vm/hardware-configuration.nix | UUID, Btrfs, аппаратные модули ВМ |
| hosts/vm/boot.nix | UEFI, systemd-boot и ядро ВМ |
| hosts/vm/guest.nix | Гостевые службы QEMU/SPICE |
| modules/system/ | Nix, локаль, сеть, пользователь, базовые утилиты |
| modules/desktop/niri.nix | Wayland/Niri, графика, шрифт и Polkit |
| modules/desktop/pipewire.nix | Звук PipeWire/WirePlumber |
| modules/desktop/login.nix | Вход с паролем через greetd/tuigreet |
| modules/desktop/firefox.nix | Браузер Firefox |
| modules/system/maintenance.nix | Команды nix-update и nix-rollback |
| modules/system/nix-update.sh | Получение, проверка и применение обновлений |
| home/nikolaev/default.nix | Общие настройки Home Manager |
| home/nikolaev/niri/config.kdl | Клавиши и минимальный вид Niri |
| home/nikolaev/ghostty.nix | Терминал |

Системные настройки и пользовательское окружение разделены.
NixOS и Home Manager используют согласованные ветки 26.05.
`system.stateVersion` ВМ сохранён как 26.05; это не переключатель обновления пакетов.
Пароль существующего nikolaev сохраняется, автоматический вход не включён.
SSH и NetworkManager сохранены; межсетевой экран включён.

## Установка на подготовленную ВМ

Диск не форматируется. UUID и структура Btrfs взяты из предоставленного
hardware-configuration.nix. Перед первым применением сделайте снимок ВМ.
Проверьте Virtio video и, если поддерживается хостом, 3D acceleration и SPICE/OpenGL.

Ниже используется **новый каталог ~/niri-clean**, чтобы не затронуть локальные
файлы прежней конфигурации. Если он уже существует, выберите другое свободное имя.
Выполняйте команды по очереди под пользователем nikolaev:

```bash
sudo cp -a /etc/nixos "/etc/nixos.before-niri-$(date +%Y%m%d-%H%M%S)"
nix-shell -p git
git clone https://github.com/nikolaevmpf/niri.git ~/niri-clean
cd ~/niri-clean
cp /etc/nixos/hardware-configuration.nix hosts/vm/hardware-configuration.nix
git add hosts/vm/hardware-configuration.nix
nix --extra-experimental-features "nix-command flakes" flake lock
git add flake.lock
nix --extra-experimental-features "nix-command flakes" flake check
sudo nixos-rebuild build --flake .#vm
```

Если любая команда завершилась ошибкой, остановитесь и разберите её до следующего шага.
Первая команда nix-shell открывает оболочку с Git — продолжайте команды внутри неё.
flake.lock создаётся на ВМ при первом запуске; он фиксирует версии зависимостей.
После успешной сборки сохраните lock и аппаратный файл коммитом в репозитории.
Не выполняйте `nix flake update` для обычного применения правок.

После успешной проверки и сборки:

```bash
sudo nixos-rebuild boot --flake .#vm
sudo reboot
```

Войдите через tuigreet с именем nikolaev и существующим паролем.
Команда запуска уже настроена на niri-session.
После входа должен появиться терминал Ghostty на тёмном фоне.

Конфигурация применяется из ~/niri-clean, а /etc/nixos остаётся резервной.
Последующие rebuild выполняйте с `--flake .#vm`, находясь в каталоге проекта.
Профиль прежнего проекта `niri-vm` больше не используется: теперь профиль **vm**.

## Управление

Super — клавиша Windows. Если хост перехватывает сочетания, используйте захват
клавиатуры просмотрщиком ВМ.

| Клавиши | Действие |
|---|---|
| Super+Enter или Super+T | Новый терминал Ghostty |
| Super+B | Firefox |
| Super+Q | Закрыть окно |
| Super+стрелки | Переместить фокус |
| Super+Ctrl+стрелки | Переместить окно/колонку |
| Super+PageUp / PageDown | Перейти между рабочими пространствами |
| Super+Ctrl+PageUp / PageDown | Перенести колонку между рабочими пространствами |
| Super+F | Развернуть колонку |
| Super+Shift+F | Полный экран |
| Super+V | Плавающее окно |
| Super+R | Изменить ширину колонки |
| Super+Shift+/ | Показать подсказку клавиш |
| Super+Shift+E | Выйти из сессии с подтверждением |
| Alt+Shift | EN/RU |

Настройка раскладок в Wayland находится в config.kdl. Настройка xkb в системном
модуле оставлена согласованной с ней; сама по себе она не включает Xorg.
Блокировщик экрана пока не установлен: для завершения сеанса используйте выход.

## Проверка

`nix flake check` вычисляет конфигурацию flake и проверяет config.kdl командой
`niri validate`. Полную систему собирает отдельный `nixos-rebuild build`.
При подготовке проверены ссылки на локальные модули и структура минимального
профиля. Nix в среде подготовки отсутствует: полная сборка и проверка графики
должны быть выполнены на ВМ.

После входа в Niri:

```bash
niri validate
niri msg outputs
wpctl status
systemctl --user status pipewire wireplumber
systemctl --user status polkit-agent
systemctl status greetd
```

`wpctl status` должен показывать доступные аудиоустройства. Для воспроизведения
звука виртуальная машина должна иметь виртуальную звуковую карту.

При ошибке сессии перейдите в TTY: Ctrl+Alt+F3, при необходимости через меню
отправки клавиш просмотрщика. После входа получите журналы:

```bash
journalctl -b -u greetd --no-pager
journalctl --user -b -u niri --no-pager
lspci -nnk
```

## Короткие команды обновления

После первого применения текущей конфигурации команды доступны из любого каталога:

| Команда | Действие |
|---|---|
| `nix-update` | Git pull, проверка, сборка и применение с текущим flake.lock |
| `nix-update --upgrade` | То же, с обновлением flake.lock в рамках веток 26.05 |
| `nix-rollback` | Переключиться на предыдущую системную генерацию |
| `nix-update --help` | Подсказка |

Команду nix-update запускайте обычным пользователем: sudo будет запрошен для сборки
и применения. Если обновилось ядро, после успешного применения нужна перезагрузка.
Изменения Firefox и конфигурации Niri обычно доступны без перезагрузки.
Super+B запускает Firefox; Ghostty по-прежнему открывается по Super+Enter.

По умолчанию используется ~/niri-clean и профиль vm. Для другого пути/хоста:

```bash
NIRI_CONFIG_DIR=~/другой-каталог NIRI_HOST=другой-профиль nix-update
```

Скрипт прекращает работу при ошибке. Локальные правки не сбрасываются: если git pull
сообщит о конфликте или разошедшихся ветках, сначала разберите его. Скрипт не делает
автоматических коммитов и push. Он добавляет flake.lock в индекс Git, чтобы новый
lock входил в Git-backed flake; после --upgrade сохраните его коммитом при необходимости.
Если сборка не удалась, действующая система не переключается, но новый flake.lock
остаётся в рабочем каталоге для разбора ошибки. Откат системы не откатывает Git-файлы.

Первое применение, пока nix-update ещё не установлен:

```bash
cd ~/niri-clean
git pull --ff-only
sudo nixos-rebuild switch --flake .#vm
```

## Последующие изменения

Добавляйте одну функцию за раз: отдельный модуль, проверка, сборка, применение.
Например, системная программа — новый файл в modules/desktop с импортом
в modules/desktop/default.nix; пользовательские настройки — в home/nikolaev.

```bash
cd ~/niri-clean
nix flake check
sudo nixos-rebuild build --flake .#vm
sudo nixos-rebuild boot --flake .#vm
sudo reboot
```

## Перенос на физический компьютер

Не копируйте аппаратный профиль ВМ на физическую машину.
Создадим отдельный hosts/<имя>, добавим его в nixosConfigurations и подключим
общие modules/system, modules/desktop и home/nikolaev.
На целевой машине потребуются собственные:
- hardware-configuration.nix и UUID дисков;
- параметры загрузчика и графического адаптера;
- system.stateVersion, соответствующая начальной установке этой машины.

Модули guest.nix и boot.nix ВМ подключаются только из hosts/vm.
Так изменения окружения останутся общими, а аппаратные настройки — раздельными.

## Откат

При неудачной загрузке удерживайте Space при старте и выберите предыдущую
генерацию NixOS в systemd-boot. Из TTY можно выполнить:

```bash
sudo nixos-rebuild switch --rollback
```

Home Manager сохраняет конфликтующие пользовательские файлы с суффиксом
.before-niri. Если такая копия уже существует, сначала переместите её в безопасное
место. Это не требует удаления домашнего каталога.
