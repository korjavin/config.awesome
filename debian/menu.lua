-- automatically generated file. Do not edit (see /usr/share/doc/menu/html)

local awesome = awesome

Debian_menu = {}

Debian_menu["Debian_Игры_Настольные"] = {
	{"eboard","/usr/games/eboard"},
}
Debian_menu["Debian_Игры"] = {
	{ "Настольные", Debian_menu["Debian_Игры_Настольные"] },
}
Debian_menu["Debian_Оконные_менеджеры"] = {
	{"awesome",function () awesome.exec("/usr/bin/awesome") end,"/usr/share/pixmaps/awesome.xpm"},
}
Debian_menu["Debian_Приложения_Normal_applications"] = {
	{"Upwork","/usr/bin/upwork",},
}
Debian_menu["Debian_Приложения_Графика"] = {
	{"dotty","/usr/bin/dotty"},
	{"lefty","/usr/bin/lefty"},
	{"The GIMP","/usr/bin/gimp","/usr/share/pixmaps/gimp.xpm"},
}
Debian_menu["Debian_Приложения_Научные_Математика"] = {
	{"Bc", "x-terminal-emulator -e ".."/usr/bin/bc"},
	{"Dc", "x-terminal-emulator -e ".."/usr/bin/dc"},
}
Debian_menu["Debian_Приложения_Научные"] = {
	{ "Математика", Debian_menu["Debian_Приложения_Научные_Математика"] },
}
Debian_menu["Debian_Приложения_Оболочки"] = {
	{"Bash", "x-terminal-emulator -e ".."/bin/bash --login"},
	{"Dash", "x-terminal-emulator -e ".."/bin/dash -i"},
	{"Sh", "x-terminal-emulator -e ".."/bin/sh --login"},
	{"Zsh", "x-terminal-emulator -e ".."/bin/zsh"},
}
Debian_menu["Debian_Приложения_Программирование"] = {
	{"Guile 2.0", "x-terminal-emulator -e ".."/usr/bin/guile-2.0"},
	{"Python (v2.6)", "x-terminal-emulator -e ".."/usr/bin/python2.6","/usr/share/pixmaps/python2.6.xpm"},
	{"Ruby (irb1.9.1)", "x-terminal-emulator -e ".."/usr/bin/irb1.9.1"},
	{"Tclsh8.5", "x-terminal-emulator -e ".."/usr/bin/tclsh8.5"},
	{"Tclsh8.6", "x-terminal-emulator -e ".."/usr/bin/tclsh8.6"},
	{"TkWish8.5","x-terminal-emulator -e /usr/bin/wish8.5"},
	{"TkWish8.6","x-terminal-emulator -e /usr/bin/wish8.6"},
}
Debian_menu["Debian_Приложения_Работа_со_звуком"] = {
	{"Audacity","/usr/bin/audacity","/usr/share/pixmaps/audacity32.xpm"},
	{"GNOME ALSA Mixer","/usr/bin/gnome-alsamixer","/usr/share/pixmaps/gnome-alsamixer/gnome-alsamixer-icon.xpm"},
	{"paprefs","/usr/bin/paprefs"},
}
Debian_menu["Debian_Приложения_Сеть_Мониторинг"] = {
	{"Mtr","mtr"},
}
Debian_menu["Debian_Приложения_Сеть_Общение"] = {
	{"Pidgin","/usr/bin/pidgin","/usr/share/pixmaps/pidgin-menu.xpm"},
	{"PuTTY","/usr/bin/putty","/usr/share/pixmaps/putty.xpm"},
	{"Ring","/usr/bin/gnome-ring"},
	{"Telnet", "x-terminal-emulator -e ".."/usr/bin/telnet.netkit"},
	{"xtightvncviewer","/usr/bin/xtightvncviewer"},
}
Debian_menu["Debian_Приложения_Сеть_Пересылка_файлов"] = {
	{"Deluge BitTorrent Client","/usr/bin/deluge","/usr/share/pixmaps/deluge.xpm"},
}
Debian_menu["Debian_Приложения_Сеть_Просмотр_веб"] = {
	{"Google Chrome","/opt/google/chrome/google-chrome","/opt/google/chrome/product_logo_32.xpm"},
	{"Google Chrome (unstable)","/opt/google/chrome-unstable/google-chrome-unstable","/opt/google/chrome-unstable/product_logo_32_dev.xpm"},
	{"Lynx", "x-terminal-emulator -e ".."lynx"},
	{"Yandex Browser (beta)","/opt/yandex/browser-beta/yandex-browser-beta","/opt/yandex/browser-beta/product_logo_32.xpm"},
}
Debian_menu["Debian_Приложения_Сеть"] = {
	{ "Мониторинг", Debian_menu["Debian_Приложения_Сеть_Мониторинг"] },
	{ "Общение", Debian_menu["Debian_Приложения_Сеть_Общение"] },
	{ "Пересылка файлов", Debian_menu["Debian_Приложения_Сеть_Пересылка_файлов"] },
	{ "Просмотр веб", Debian_menu["Debian_Приложения_Сеть_Просмотр_веб"] },
}
Debian_menu["Debian_Приложения_Системные_Администрирование"] = {
	{"Debian Task selector", "x-terminal-emulator -e ".."su-to-root -c tasksel"},
	{"Editres","editres"},
	{"Orphaner (all)", "x-terminal-emulator -e ".."su-to-root -c '/usr/sbin/orphaner -a'"},
	{"Orphaner - editkeep", "x-terminal-emulator -e ".."su-to-root -c '/usr/sbin/editkeep'"},
	{"Orphaner (libs)", "x-terminal-emulator -e ".."su-to-root -c /usr/sbin/orphaner"},
	{"UNetbootin","/usr/bin/unetbootin","/usr/share/pixmaps/unetbootin.xpm"},
	{"Xfontsel","xfontsel"},
	{"Xkill","xkill"},
	{"Xrefresh","xrefresh"},
}
Debian_menu["Debian_Приложения_Системные_Аппаратное_обеспечение"] = {
	{"Driconf","/usr/bin/driconf"},
	{"Xvidtune","xvidtune"},
}
Debian_menu["Debian_Приложения_Системные_Мониторинг"] = {
	{"Pstree", "x-terminal-emulator -e ".."/usr/bin/pstree.x11","/usr/share/pixmaps/pstree16.xpm"},
	{"Top", "x-terminal-emulator -e ".."/usr/bin/top"},
	{"Xev","x-terminal-emulator -e xev"},
}
Debian_menu["Debian_Приложения_Системные_Управление_пакетами"] = {
	{"Aptitude Package Manager (text)", "x-terminal-emulator -e ".."/usr/bin/aptitude-curses"},
}
Debian_menu["Debian_Приложения_Системные"] = {
	{ "Администрирование", Debian_menu["Debian_Приложения_Системные_Администрирование"] },
	{ "Аппаратное обеспечение", Debian_menu["Debian_Приложения_Системные_Аппаратное_обеспечение"] },
	{ "Мониторинг", Debian_menu["Debian_Приложения_Системные_Мониторинг"] },
	{ "Управление пакетами", Debian_menu["Debian_Приложения_Системные_Управление_пакетами"] },
}
Debian_menu["Debian_Приложения_Управление_данными"] = {
	{"Revelation","/usr/bin/revelation","/usr/share/pixmaps/revelation.xpm"},
}
Debian_menu["Debian_Приложения_Эмуляторы"] = {
	{"VirtualBox","/usr/bin/virtualbox","/usr/share/pixmaps/virtualbox.xpm"},
}
Debian_menu["Debian_Приложения_Эмуляторы_терминалов"] = {
	{"X-Terminal as root (GKsu)","/usr/bin/gksu -u root /usr/bin/x-terminal-emulator","/usr/share/pixmaps/gksu-debian.xpm"},
}
Debian_menu["Debian_Приложения"] = {
	{ "Normal applications", Debian_menu["Debian_Приложения_Normal_applications"] },
	{ "Графика", Debian_menu["Debian_Приложения_Графика"] },
	{ "Научные", Debian_menu["Debian_Приложения_Научные"] },
	{ "Оболочки", Debian_menu["Debian_Приложения_Оболочки"] },
	{ "Программирование", Debian_menu["Debian_Приложения_Программирование"] },
	{ "Работа со звуком", Debian_menu["Debian_Приложения_Работа_со_звуком"] },
	{ "Сеть", Debian_menu["Debian_Приложения_Сеть"] },
	{ "Системные", Debian_menu["Debian_Приложения_Системные"] },
	{ "Управление данными", Debian_menu["Debian_Приложения_Управление_данными"] },
	{ "Эмуляторы", Debian_menu["Debian_Приложения_Эмуляторы"] },
	{ "Эмуляторы терминалов", Debian_menu["Debian_Приложения_Эмуляторы_терминалов"] },
}
Debian_menu["Debian_Справка"] = {
	{"Info", "x-terminal-emulator -e ".."info"},
}
Debian_menu["Debian"] = {
	{ "Игры", Debian_menu["Debian_Игры"] },
	{ "Оконные менеджеры", Debian_menu["Debian_Оконные_менеджеры"] },
	{ "Приложения", Debian_menu["Debian_Приложения"] },
	{ "Справка", Debian_menu["Debian_Справка"] },
}

debian = { menu = { Debian_menu = Debian_menu } }
return debian