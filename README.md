# NixOS + Niri: минимальная модульная конфигурация

Начинаем с чистой основы. Активный профиль: **vm**, имя компьютера: **niri-vm**,
пользователь: **nikolaev**, NixOS **26.05**, архитектура **x86_64-linux**.

Первый этап: Niri (Wayland-композитор), PipeWire + WirePlumber, терминал Ghostty,
минимальный экран входа greetd/tuigreet, браузер Firefox. Сразу после входа запускается Ghostty.
Установлены Git, Nano, pciutils, duf, mc, ncdu, nmap, lazyssh, wget, curl и usbutils.
Файловый менеджер — Nautilus; курсор — Bibata Modern Classic, 24 px.
Wayland и порталы настраивает штатный модуль NixOS `programs.niri`.
Xorg-сессия не включена.

Добавлена собственная начальная панель Quickshell: запуск приложений, часы и выход.
Меню всех приложений, уведомления и системный трей пока не реализованы.
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
| modules/desktop/nautilus.nix | Файловый менеджер, GVfs и UDisks2 |
| modules/system/cleanup.nix | Автоматическая очистка и оптимизация Nix |
| home/nikolaev/appearance.nix | Курсор Bibata Modern Classic |
| home/nikolaev/nautilus.nix | Стандартные папки и открытие каталогов в Nautilus |
| modules/system/maintenance.nix | Команды nix-update и nix-rollback |
| modules/system/nix-update.sh | Получение, проверка и применение обновлений |
| home/nikolaev/default.nix | Общие настройки Home Manager |
| home/nikolaev/niri/config.kdl | Клавиши и минимальный вид Niri |
| home/nikolaev/ghostty.nix | Терминал |
| home/nikolaev/quickshell/default.nix | Пакет Quickshell, файлы и автозапуск |
| home/nikolaev/quickshell/config/shell.qml | Главный файл оболочки |
| home/nikolaev/quickshell/config/components/ | Панель, кнопки, часы |
| home/nikolaev/quickshell/config/theme/ | Цвета, размеры, шрифты |

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
| Super+E | Файловый менеджер Nautilus |
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

## Файлы, утилиты и курсор

Nautilus запускается по Super+E или командой `nautilus`.
GVfs и UDisks2 включены для работы с томами и подключениями.
Стандартные пользовательские каталоги создаются через Home Manager.

Утилиты доступны в терминале: `duf`, `mc`, `ncdu`, `nmap`, `lazyssh`,
`wget`, `curl`, `lsusb` (последняя входит в usbutils).

Bibata-Modern-Classic установлен размером 24 px, одинаково задан в Niri и
Home Manager/GTK. После первого применения выйдите из Niri и войдите снова,
чтобы новые переменные окружения применились ко всем приложениям.

## Автоматическая очистка

Каждый понедельник около 04:00–04:30 по местному времени (Europe/Moscow)
Nix удаляет поколения профилей старше 30 дней, затем неиспользуемые объекты
из /nix/store. Текущие поколения профилей сохраняются.
Удалённые старые поколения больше не будут доступны для отката.
Параметр boot.loader.systemd-boot.configurationLimit = 10 дополнительно ограничивает
число записей загрузочного меню; это не замена сборке мусора.

Таймер persistent: если ВМ была выключена, пропущенная очистка выполняется после
включения с возможной случайной задержкой до 30 минут.
Содержимое домашнего каталога, корзина и загрузки этой настройкой не очищаются.
Оптимизация хранилища автоматически объединяет одинаковые файлы жёсткими ссылками.

Проверка таймера и журнала:

```bash
systemctl list-timers nix-gc.timer
journalctl -u nix-gc.service --no-pager -n 50
```

При необходимости ручной запуск той же очистки:

```bash
sudo systemctl start nix-gc.service
```

## Начальная оболочка Quickshell

Используется пакет quickshell из той же ветки nixpkgs 26.05.
Новых flake inputs и отдельного набора Qt-зависимостей не требуется.

Панель располагается сверху с отступом 8 px, имеет высоту 48 px и закругление 12 px.
Niri резервирует для неё место, окна не должны перекрывать панель.
Создаётся отдельная панель на каждом экране; имена и разрешения мониторов
в конфигурации не зашиты. На небольшом экране подписи кнопок сокращаются.

Кнопки: Ghostty, Firefox, Nautilus и выход из Niri с подтверждением.
По центру находятся дата и время. Начальная версия не содержит рабочего стола
с иконками, трея, уведомлений, громкости и списка рабочих пространств.

Файлы QML устанавливаются Home Manager в ~/.config/quickshell/niri.
Редактируйте исходники в ~/niri-clean/home/nikolaev/quickshell/config,
затем применяйте через nix-update. Файлы в ~/.config управляются Nix.

Для первого применения и запуска в текущей сессии:

```bash
nix-update
systemctl --user daemon-reload
systemctl --user start quickshell.service
```

После следующего входа Quickshell запускается автоматически вместе с
graphical-session.target и останавливается при выходе.
В config.kdl отдельного запуска Quickshell нет — второй экземпляр не создаётся.
После последующих изменений QML выполните:

```bash
systemctl --user restart quickshell.service
```

Проверка и журнал:

```bash
systemctl --user status quickshell.service
journalctl --user -u quickshell.service -b --no-pager -n 80
```

Чтобы увидеть ошибку запуска прямо в терминале, сначала остановите службу:

```bash
systemctl --user stop quickshell.service
quickshell -c niri
```

Закончите ручной запуск через Ctrl+C и верните службу командой
`systemctl --user start quickshell.service`.

Временное отключение панели: `systemctl --user stop quickshell.service`.
Горячие клавиши Niri при этом продолжают работать.

Проверена структура QML-компонентов и подключение модуля; Qt/Quickshell и Nix
в среде подготовки отсутствуют. Проверка сборки и фактического отображения
панели выполняется на ВМ после применения.

Документация:
https://quickshell.org/docs/

## Цветовая палитра Catppuccin

Вариант: **Mocha**, акцент: **Blue**.

| Элемент | Настройка |
|---|---|
| Quickshell | Цвета в home/nikolaev/quickshell/config/theme/Theme.qml |
| Ghostty | Полная палитра из 16 ANSI-цветов в home/nikolaev/ghostty.nix |
| Niri | Фон Mocha Base, фон обзора Crust, голубая рамка активного окна |
| GTK3 | catppuccin-mocha-blue-standard |
| GTK4 / Nautilus | Та же тема через gtk.gtk4.theme и CSS Home Manager |

Основные цвета: фон #1e1e2e, текст #cdd6f4, акцент #89b4fa,
поверхности #313244 и #45475a. Курсор Bibata Modern Classic сохранён.

Применение:

```bash
nix-update
systemctl --user restart quickshell.service
```

Затем закройте и откройте Nautilus и Ghostty. Для гарантированного перезапуска
Nautilus можно выполнить `nautilus -q`, а затем `nautilus`.
Внутри GTK4 применяется пользовательский CSS; отдельные элементы некоторых
libadwaita-приложений могут отличаться. Qt-приложения и собственные темы браузера
этим GTK-модулем не перенастраиваются.

Полную сборку и отображение GTK-темы необходимо проверить на ВМ.
