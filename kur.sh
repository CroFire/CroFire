#!/bin/bash

clear
    
PLNK="/home/$USER/.config/plank/dock1"
CROFIRE="/home/$USER/Downloads/CROFIRE/crofire"
EXTENC="/home/$USER/.local/share/gnome-shell/extensions"

OS=$(cat /etc/os-release | grep '^ID=' | cut -c4-10)
if [[ "$OS" = 'arch' ]]; then 
    if ! sudo pacman -Qq 'dialog' 2>0; then
	clear; sudo pacman -S 'dialog' --noconfirm --needed
    fi
fi
[[ -e $HOME/.dialogrc ]] && mv $HOME/.dialogrc $HOME/.olddialogrc
[[ -e $HOME/.dialogrc ]]  || mv $CROFIRE/.dialogrc $HOME/
sleep .2

if [[ ! "$DESKTOP_SESSION" = 'gnome' ]]; then 
    dialog --infobox '\n\n  Uygulama yalnızca Gnome Masaüstüne Uyumludur !\n\n  Kurulumdan Çıkılıyor .... \n\n' 10 55
        sleep 4; clear; exit 0
            else
    if [[ ! -x /bin/plank ]]; then
	dialog --infobox '\n\n  Uygulama için Plank Rıhtım Uygulaması Gerekmektedir !\n\n  Kurulumdan Çıkılıyor .... \n\n' 10 60
            sleep 4; clear; exit 0
     fi
fi

if sudo pacman -Qq pacman &>0; then
    if ! sudo pacman -Qq xdotool wmctrl gtkdialog &>0; then
	dialog --yesno "\n Birkaç tane ek paket kurulacak.\n\n Bunların dahil edilmesini onaylıyormusunuz ?\n\n\n  xdotool wmctrl gtkdialog" 12 53
	    if [ $? -eq 0 ]; then clear; sudo pacman -Sy xdotool wmctrl gtkdialog --noconfirm --needed
		else exit 0
	    fi
      fi
fi

(
[[ -d $PLNK ]] || mkdir -p $PLNK
[[ -d $EXTENC ]] || mkdir -p $EXTENC
rm -rf $PLNK/crofire 2>0; sleep .3
mv $CROFIRE $PLNK 2>0; sleep .3
chmod +x $PLNK/crofire/*.sh 2>0; sleep .3

if [[ -d $PLNK/crofire ]]; then
    mkdir -p $PLNK/OLD
    mv $PLNK/launchers/firefox.dockitem $PLNK/OLD 2>0
    mv $PLNK/launchers/google-chrome.dockitem $PLNK/OLD 2>0
    mv $PLNK/launchers/chromium.dockitem $PLNK/OLD 2>0
    else
    dialog --infobox '\n\n  Dosya Konumlama Hatası Bulundu !\n\n  Kurulumdan Çıkılıyor .... \n\n' 10 50
    sleep 3; clear; exit 0
fi

if [[ -d $PLNK/crofire ]]; then
    sed -i $A's|USER|'$USER'|g' $PLNK/crofire/fire.desktop 2>0; sleep .3
    sed -i $A's|USER|'$USER'|g' $PLNK/crofire/google.desktop 2>0; sleep .3
    sed -i $A's|USER|'$USER'|g' $PLNK/crofire/chromi.desktop 2>0; sleep .3
fi

if [[ -d $EXTENC/auto-move-windows@gnome-shell-extensions.gcampax.github.com ]]; then
    rm $EXTENC/auto-move-windows@gnome-shell-extensions.gcampax.github.com/schemas/org.gnome.shell.extensions.auto-move-windows.gschema.xml 2>0
	sudo mv $CROFIRE/org.gnome.shell.extensions.auto-move-windows.gschema.xml /usr/share/glib-2.0/schemas/
            else
	mv $CROFIRE/auto-move-windows@gnome-shell-extensions.gcampax.github.com $EXTENC/
    sudo mv $CROFIRE/org.gnome.shell.extensions.auto-move-windows.gschema.xml /usr/share/glib-2.0/schemas/
fi

sudo glib-compile-schemas /usr/share/glib-2.0/schemas 2>0
       
sleep 4

if [[ -e $PLNK/OLD/firefox.dockitem ]]; then
    echo -e "[PlankDockItemPreferences]\nLauncher=file://$PLNK/crofire/fire.desktop" > $PLNK/launchers/fire.dockitem
    fi
if [[ -e $PLNK/OLD/google-chrome.dockitem ]]; then
    echo -e "[PlankDockItemPreferences]\nLauncher=file://$PLNK/crofire/google.desktop" > $PLNK/launchers/google.dockitem
    fi
if [[ -e $PLNK/OLD/chromium.dockitem ]]; then
    echo -e "[PlankDockItemPreferences]\nLauncher=file://$PLNK/crofire/chromi.desktop" > $PLNK/launchers/chromi.dockitem
    fi
) | for say in {1..100}; do sleep .08 ; echo $say | dialog --gauge "\n\n  Ayarlamalar Yapılıyor ....\n" 10 65; done

_GChrome () {
Xgoogle=$(ls /bin/google-chrome* | sed 's/\/bin\///') 
    $Xgoogle 2>0 & wait $! ; sleep 2
	Glck="$HOME/.config/google-chrome"
	    if [[ -d $Glck/crofire ]]; then rm -r $Glck/crofire 
	        mkdir -p $Glck/crofire ; cp $Glck/Default/Preferences $Glck/crofire/ 
	    else
	mkdir -p $Glck/crofire ; cp $Glck/Default/Preferences $Glck/crofire/
    fi
}

if [[ -e $PLNK/OLD/google-chrome.dockitem ]]; then
	dialog --yesno "\n İsteğe bağlı olarak Google Chrome uygulamasının ayarlarını\n sabitleyebilirsiniz.\n\n\n Evet seçeneğini kullanırsanız, Google Chrome açılacak ve\n kapattığınız zamanki ayarlarınız nasıl ise bundan sonra\n aynı ayarlar kullanılacak \n\n\n Bu ayarlar şunları içerir; \n\n .. Uygulamanın boyut ve konum ayarları.\n\n .. Tarayıcı geçmişi tutma ve temizleme ayarları.\n\n .. Eklenti seçenekleri ve görünürlüğü.\n\n .. Yazı stili ve boyut ayarları.\n\n\n Not: Bu ayarlardan site tercihleri (bookmark) için \n\n yaptığınız düzenlemeler etkilenmez !" 30 63
if [ $? -eq 0 ]; then _GChrome ; fi 
    if [ $? -eq 1 ]; then sed -i 's/cp ~\//#cp ~\//' $PLNK/crofire/google.sh
    fi
fi

_Chromium () {
chromium 2>0 & wait $! ; sleep 2
    Clck="$HOME/.config/chromium"
	if [[ -d $Clck/crofire ]]; then rm -r $Clck/crofire
	    mkdir -p $Clck/crofire ; cp $Clck/Default/Preferences $Clck/crofire/
	else
    mkdir -p $Clck/crofire ; cp $Clck/Default/Preferences $Clck/crofire/
fi
}

if [[ -e $PLNK/OLD/chromium.dockitem ]]; then
	dialog --yesno "\n İsteğe bağlı olarak Chromium uygulamasının ayarlarını\n sabitleyebilirsiniz.\n\n\n Evet seçeneğini kullanırsanız, Chromium açılacak ve\n kapattığınız zamanki ayarlarınız nasıl ise bundan sonra\n aynı ayarlar kullanılacak \n\n\n Bu ayarlar şunları içerir; \n\n .. Uygulamanın boyut ve konum ayarları.\n\n .. Tarayıcı geçmişi tutma ve temizleme ayarları.\n\n .. Eklenti seçenekleri ve görünürlüğü.\n\n .. Yazı stili ve boyut ayarları.\n\n\n Not: Bu ayarlardan site tercihleri (bookmark) için \n\n yaptığınız düzenlemeler etkilenmez !" 30 63
if [ $? -eq 0 ]; then _Chromium; fi
    if [ $? -eq 1 ]; then sed -i 's/cp ~\//#cp ~\//' $PLNK/crofire/chromium.sh
    fi
fi

[[ -e $HOME/.olddialogrc ]] && mv $HOME/.olddialogrc $HOME/.dialogrc || rm $HOME/.dialogrc
[[ -d $CROFIRE ]]  || rm -R /home/$USER/Downloads/CROFIRE* 2>0 



dialog --infobox "\n\n    Kurulum işlemi tamamlandı :)\n\n" 7 43 ; sleep 3
clear
exit

