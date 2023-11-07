#!/bin/bash

#colores
rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores
#fin de colores

#toma el control de control + c
trap ctrl_c INT
function ctrl_c()
{
clear
figlet -c Gracias por
figlet -c utilizar mi
figlet -c script
wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz 2>/dev/null 1>/dev/null 0>/dev/null
exit
}
#Fin de control de control c

#funcion de menu principal
function menu(){
while :
do
clear
wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz 2>/dev/null 1>/dev/null 0>/dev/null
source /home/$(whoami)/.config_montar_unidades/montar_unidades 2>/dev/null 1>/dev/null 0>/dev/null
echo -e "${rosa}"; figlet -c sukigsx; echo -e "${borra_colores}"
echo -e""
echo -e "${verde} Diseñado por sukigsx / Contacto:  scripts@mbbsistemas.es${borra_colores}"
echo -e "${verde}                                   https://repositorio.mbbsistemas.es/${borra_colores}"
echo -e ""
echo -e "${verde} Nombre del script < montar_unidades.sukigsx.sh >${borra_colores}"
echo -e ""
if [ $configurado = "si" ]
then
    echo -e "${azul} Estado de la configuracion del script. Configurado = ${verde}$configurado${borra_colores}."
else
    echo -e "${azul} Estado de la configuracion del script. Configurado = ${rojo}$configurado${borra_colores}."
fi

if [ $actualizado = "si" ]
then
    echo -e "${azul} Estado de actualizacion del script = ${verde}$actualizado${borra_colores}."
else
    echo -e "${azul} Estado de actualizacion del script = ${rojo}$actualizado${borra_colores}."
fi
echo -e ""
echo -e " 0.${azul} Actualiza este script.${borra_colores}"
echo ""
echo -e " 1. ${azul}Ver/editar fichero de configuracion.${borra_colores}"
echo -e ""
echo -e " 2. ${azul}Ver direcciones ip de tu red.${borra_colores}"
echo -e " 3. ${azul}Ver carpetas compartidas de tu servidor.${borra_colores}"
echo -e ""
echo -e " 4. ${azul}Configurar de nuevo las unidades a montar.${borra_colores}"
echo -e ""
echo -e " 5. ${azul}Montar las unidades.${borra_colores}"
echo -e " 6. ${azul}Desmontar todas las unidades.${borra_colores}"
echo -e ""
echo -e " 7. ${azul}Montar las unidades al inicio del sistema. Y acceso directo en tu escritrio.${borra_colores}"
echo ""
echo -e " 8. ${rojo}Eliminar toda la configuracion.${borra_colores}"
echo -e " 9. ${rojo}Desistalar el script.${borra_colores}"
echo -e ""
echo -e " 90. ${azul}Ayuda.${borra_colores}"
echo -e ""
echo -e " 99. ${azul}Atras / Salir.${borra_colores}"
echo ""
echo -n " Seleccione una opcion -> "; read opcion
case $opcion in
    0)  #actualiza el script
        archivo_local="montar_unidades.sukigsx.sh" # Nombre del archivo local
        ruta_repositorio="https://github.com/sukigsx/montar_unidades.git" #ruta del repositorio para actualizar y clonar con git clone

        # Obtener la ruta del script
        descarga=$(dirname "$(readlink -f "$0")")
        git clone $ruta_repositorio /tmp/comprobar >/dev/null 2>&1

        diff $descarga/$archivo_local /tmp/comprobar/$archivo_local >/dev/null 2>&1


        if [ $? = 0 ]
        then
            #esta actualizado, solo lo comprueba
            echo ""
            echo -e "${verde} El script${borra_colores} $0 ${verde}esta actualizado.${borra_colores}"
            echo ""
            chmod -R +w /tmp/comprobar
            rm -R /tmp/comprobar
        else
            #hay que actualizar, comprueba y actualiza
            echo ""
            echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
            echo -e "${verde} Se procede a su actualizacion automatica.${borra_colores}"
            sleep 3
            mv /tmp/comprobar/$archivo_local $descarga
            chmod -R +w /tmp/comprobar
            rm -R /tmp/comprobar
            echo ""
            echo -e "${verde} El script se ha actualizado, es necesario cargarlo de nuevo.${borra_colores}"
            echo -e "${amarillo} Se cerrara el terminal en 5 segundos.${borra_colores}"
            sleep 5
            xdotool windowkill `xdotool getactivewindow`
        fi
        ;;

    1)  #configuracion
        clear
        nano /home/$(whoami)/.config/config_montar_unidades
        source /home/$(whoami)/.config/config_montar_unidades 2>/dev/null 1>/dev/null 0>/dev/null
        ;;

    2)  #ver direcciones ip de tu red
        ip=$(route -n | awk '{print $2}' | grep 192) #saca la ip de la puerta de enlace
        if ping -c 3 $ip 2>/dev/null 1>/dev/null 0>/dev/null #comprueba la conexion a la puerta de enlace
        then
            clear
            echo -e ""
            echo -e "${azul} Listado de direcciones ip donde estara tu servidor samba.${verde}"
            echo -e ""
            arp | grep ether | awk '{print $1}' | sed 's/_gateway/ /'
            echo -e "${borra_colores}"
            echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
            read pause
        else
            clear
            echo -e ""
            echo -e "${rojo} Imposible conectar a la red lan. ${amarillo}$ip_servidor_samba${rojo}.${borra_colores}"
            echo -e ""
            echo -e "    ${azul}No existe conexion a la red.${borra_colores}"
            echo -e ""
            echo -e " Revisa el fichero de configuracion, opcion 1 del menu."
            echo -e " Pulsa una tecla para continuar."
            read pause
        fi
        ;;

    3)  #ver carpetas compartidas de tu servidor
        if [ $configurado = "si" ]
        then
            if smbclient -L //$ip_servidor_samba/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
            then
                clear
                echo -e "\n ${azul}Listado de carpetas compartidas.${borra_colores}"
                echo -e ""
                echo -e "${verde}"
                smbclient -L //$ip_servidor_samba/ -U=$usuario_servidor_samba%$password_servidor_samba | grep Disk | awk '{print "     " $1}'
                echo -e ""
                echo -e "${azul} Fin del listado de las carpetas de tu servidor samba.${borra_colores}"
                echo -e ""
                echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
                read pasue
            else
                clear
                echo -e ""
                echo -e "${rojo} Imposible conectar con el servidor ${amarillo}$ip_servidor_samba${rojo}.${borra_colores}"
                echo -e ""
                echo -e " Los datos de acceso al servidor son erroneos. Posibles causas:"
                echo -e ""
                echo -e "   1- ${azul}No existe conexion al servidor en la red.${borra_colores}"
                echo -e "   2- ${azul}El usuario esta mal introducido en el fichero de configuracion.${borra_colores}"
                echo -e "   3- ${azul}La password esta mal introducida en el fichero de configuracion.${borra_colores}"
                echo -e "   4- ${azul}Todas las anteriores.${borra_colores}"
                echo -e ""
                echo -e " Revisa el fichero de configuracion, opcion 1 del menu."
                echo -e " Pulsa una tecla para continuar."
                read pause
            fi
        else
            clear
            echo -e ""
            echo -e "${rojo} Fichero de configuracion NO esta configurado.${borra_colores}"
            echo -e "${amarillo} Selecciona opcion 1 del menu para configurar.${borra_colores}"
            echo -e ""
            echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
            read pasue
        fi
        ;;

    4)  #configurar de nuevo las unidades a montar
        clear
        echo -e ""
        echo -e "${verde} Desmontando unidades.${borra_colores}"
        echo -e ""
        for unidad in $carpetas
        do
            if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
            then
                sudo umount /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
                echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} desmontada correctamente."
                sleep 2
            else
                echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada. Imposible desmontar."
                sleep 2
            fi
            done
        clear
        echo -e ""
        echo -e "${amarillo} Se borra fichero de configuracion.${borra_colores}"
        echo -e "${amarillo} Se borraran las carpetas incluidas en: /home/$(whoami)/servidor_samba/${borra_colores}"
        echo -e ""
        echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
        read pasue
        sudo rm -r /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
        configuracion
        ;;

    5)  #Montar las unidades.
        if [ $configurado = "si" ]
        then
            if smbclient -L //$ip_servidor_samba/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
            then
                clear
                echo -e ""
                echo -e "${verde} Montando las unidades.${borra_colores}"
                echo -e ""
                for unidad in $carpetas
                do
                if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
                then
                    mkdir /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
                    mkdir /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
                    sudo mount -t cifs  //$ip_servidor_samba/$unidad /home/$(whoami)/servidor_samba/$unidad -o user=$usuario_servidor_samba,password=$password_servidor_samba,uid=$usuario_servidor_samba,gid=$usuario_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
                    echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} montada correctamente."
                    sleep 2
                else
                    echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada"
                    sleep 2
                fi
                done

                echo -e ""
                echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
                read pasue
            else
                clear
                echo -e ""
                echo -e "${rojo} Imposible conectar con el servidor ${amarillo}$ip_servidor_samba${rojo}.${borra_colores}"
                echo -e ""
                echo -e " Los datos de acceso al servidor son erroneos. Posibles causas:"
                echo -e ""
                echo -e "   1- ${azul}No existe conexion al servidor en la red.${borra_colores}"
                echo -e "   2- ${azul}El usuario esta mal introducido en el fichero de configuracion.${borra_colores}"
                echo -e "   3- ${azul}La password esta mal introducida en el fichero de configuracion.${borra_colores}"
                echo -e "   4- ${azul}Todas las anteriores.${borra_colores}"
                echo -e ""
                echo -e " Revisa el fichero de configuracion, opcion 1 del menu."
                echo -e " Pulsa una tecla para continuar."
                read pause
                menu
            fi

        else
            clear
            echo -e ""
            echo -e "${rojo} Fichero de configuracion NO esta configurado.${borra_colores}"
            echo -e "${amarillo} Selecciona opcion 1 del menu para configurar.${borra_colores}"
            echo -e ""
            echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
            read pasue
            menu
        fi
        ;;

    6)  #Desmontar las unidades.
        if [ $configurado = "si" ]
        then
            clear
            echo -e ""
            echo -e "${verde} Desmontando unidades.${borra_colores}"
            echo -e ""
            for unidad in $carpetas
            do
                if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
                then
                    sudo umount /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
                    echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} desmontada correctamente."
                    sleep 2
                else
                    echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada. Imposible desmontar."
                    sleep 2
                fi
            done
            echo -e ""
            echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
            read pasue
        else
            clear
            echo -e ""
            echo -e "${rojo} Fichero de configuracion NO esta configurado.${borra_colores}"
            echo -e "${amarillo} Selecciona opcion 1 del menu para configurar.${borra_colores}"
            echo -e ""
            echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
            read pasue
            menu
        fi
        ;;

    7)  #Montar las unidades al inicio del sistema. con crontab
        #crea un fichero script de montaje ( .montar_crontab )
        source /home/$(whoami)/.config/config_montar_unidades
        if [ $configurado = "si" ]
        then
            if smbclient -L //$ip_servidor_samba/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
            then
                clear
                echo -e ""
                echo -e "${verde} Configurando montaje de unidades automatico mediante (crontab).${borra_colores}"
                echo -e ""
                unidades_correctas=0
                for unidad in $carpetas
                do
                    if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
                    then

                        echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} incluida a montaje automatico."
                        sleep 2

                    else

                        echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO disponible. Revisa fichero configuracion, opcion 1."
                        unidades_correctas=1
                        sleep 2

                    fi
                done
                if [ $unidades_correctas = 1 ]
                then
                    echo -e ""
                    echo -e "\n ${rojo}Error de carpetas compartidas del servidor samba ($ip_servidor_samba).${borra_colores}"
                    echo -e "${amarillo} Selecciona opcion 1 del menu para configurar.${borra_colores}"
                    echo -e ""
                    echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
                    read pasue
                    menu
                fi


            else
                clear
                echo -e ""
                echo -e "${rojo} Imposible conexion con el servidor samba.${borra_colores}"
                echo -e "${amarillo} Selecciona opcion 1 del menu para configurar.${borra_colores}"
                echo -e ""
                echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
                read pasue
                menu
            fi
        else
            clear
            echo -e ""
            echo -e "${rojo} Fichero de configuracion NO esta configurado.${borra_colores}"
            echo -e "${amarillo} Selecciona opcion 1 del menu para configurar.${borra_colores}"
            echo -e ""
            echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
            read pasue
            menu
        fi
        echo -e ""
        echo -e "${verde} Se van a realizar las siguientes operaciones:${borra_colores}"
        echo -e ""
        echo -e "${verde}   -${azul} Se se creara un fichero en ${amarillo}(/home/$(whoami)/.config/montar_unidades_automatico)${azul} y dentro de el${borra_colores}"
        echo -e "${azul}     estaran las lineas necesarias para que se monten todas las unidades que tengas configuradas.${borra_colores}"
        echo -e ""
        echo -e "${azul}    - Se creara un acceso directo en tu escritio."
        echo -e ""
        echo -e "${verde}   -${azul} Se metera una linea en tu fichero ${amarillo}(crontab)${azul}, que se encargara de ejecutar en cada reinicio${borra_colores}"
        echo -e "${azul}     de tu sistema. Ejecutara el fichero ${amarillo}montar_unidades_automatico${azul}.${borra_colores}"
        echo -e "${azul}     La orden es ${amarillo}@reboot bash /home/$(whoami)/.config/montar_unidades_automatico${azul}.${borra_colores}"
        echo -e ""
        echo -e "${verde}  -${azul} Se incluira en el fichero ${amarillo}(sudores)${azul} las siguientes ordenes:${borra_colores}"
        echo -e "${amarillo}     $(whoami) ALL=(ALL) NOPASSWD: /bin/umount${borra_colores}"
        echo -e "${amarillo}     $(whoami) ALL=(ALL) NOPASSWD: /bin/mount${borra_colores}"
        echo -e "${azul}     Para que se puedean montar las unidades sin que pida la password de usuario.${borra_colores}"
        echo -e ""
        read -p " Estas deacuerdo ? (s/n) -->> " sino
        if [[ $sino = "s" ]] || [[ $sino = "S" ]] 2>/dev/null 1>/dev/null 0>/dev/null
        then
            #elimina /home/$(whoami)/.config/montar_unidades_automatico
            rm /home/$(whoami)/.config/montar_unidades_automatico 2>/dev/null 1>/dev/null 0>/dev/null

            #elimina linea de @reboot de crontab
            crontab -u $(whoami) -l | grep -v "@reboot bash /home/$(whoami)/.config/montar_unidades_automatico"  | crontab -u $(whoami) - 2>/dev/null 1>/dev/null 0>/dev/null

            #elimina las lineas en /etc/sudoers (sudo visudo)
            sudo sed -i "/$(whoami) ALL=(ALL) NOPASSWD:/d" /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null

            #le mete un retraso de 10s al fichero monta_unidades_automatico
            echo "sleep 10" >> /home/$(whoami)/.config/montar_unidades_automatico

            #crea el acceso directo en el escritorio
            echo "[Desktop Entry]" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Comment[es_ES]=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Comment=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Exec=echo Montando unidades; bash /home/$(whoami)/.config/montar_unidades_automatico; clear; echo Unidades montadas; sleep 3" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "GenericName[es_ES]=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "GenericName=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Icon=drive-harddisk" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "MimeType=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Name[es_ES]=Unidades-Automaticas" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Name=Unidades-automaticas" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Path=/bin/" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "StartupNotify=true" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Terminal=true" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "TerminalOptions=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "Type=Application" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "X-DBUS-ServiceName=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "X-DBUS-StartupType=none" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "X-KDE-SubstituteUID=false" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop
            echo "X-KDE-Username=" >> /home/$(whoami)/Escritorio/Unidades_automaticas.desktop

            for unidad in $carpetas
            do
                echo "mkdir /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null" >> /home/$(whoami)/.config/montar_unidades_automatico
                echo "mkdir /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null" >> /home/$(whoami)/.config/montar_unidades_automatico
                echo "sudo mount -t cifs  //$ip_servidor_samba/$unidad /home/$(whoami)/servidor_samba/$unidad -o user=$usuario_servidor_samba,password=$password_servidor_samba,uid=$usuario_servidor_samba,gid=$usuario_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null" >> /home/$(whoami)/.config/montar_unidades_automatico
            done

            echo -e ""
            echo -e " [${verde}V${borra_colores}] Fichero ${verde}/home/$(whoami)/.config/montar_unidades_automatico${borra_colores} creado."
            sleep 2

            #crea la entrada en el crontab
            (crontab -u $(whoami) -l; echo "@reboot bash /home/$(whoami)/.config/montar_unidades_automatico" ) | crontab -u $(whoami) -
            echo -e " [${verde}V${borra_colores}] Fichero ${verde}/home/$(whoami) Tarea crontab${borra_colores} creada."
            sleep 2

            #modifica el fichero sudoers
            echo "$(whoami) ALL=(ALL) NOPASSWD: /bin/umount" | sudo EDITOR="tee -a" visudo 1>/dev/null
            echo "$(whoami) ALL=(ALL) NOPASSWD: /bin/mount" | sudo EDITOR="tee -a" visudo 1>/dev/null
            echo -e " [${verde}V${borra_colores}] Fichero ${verde}/home/$(whoami) sudoers${borra_colores} modificado."
            sleep 2
            ctrl_c
        else
            menu
        fi
        ;;

    8)  #eliminar toda la configuracion
        #desmnonta y despues elimina las carpetas
        clear
        echo -e ""
        echo -e "${verde} Desmontando unidades.${borra_colores}"
        echo -e ""
        for unidad in $carpetas
        do
            if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
            then
                sudo umount /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
                echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} desmontada correctamente."
                sleep 2
            else
                echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada. Imposible desmontar."
                sleep 2
            fi
            done
        clear
        echo -e ""
        echo -e "${amarillo} Se borra fichero de configuracion.${borra_colores}"
        echo -e "${amarillo} Se borraran las carpetas incluidas en: /home/$(whoami)/servidor_samba/${borra_colores}"
        echo -e ""
        echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
        read pasue

        sudo rm /home/$(whoami)/.config/montar_unidades_automatico 2>/dev/null 1>/dev/null 0>/dev/null
        sudo rm -r /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
        sudo rm -r /home/$(whoami)/Escritorio/Unidades_automaticas.desktop 2>/dev/null 1>/dev/null 0>/dev/null
        sudo rm /home/$(whoami)/.config/config_montar_unidades 2>/dev/null 1>/dev/null 0>/dev/null
        sudo sed -i '/montar_unidades_automatico/d' /var/spool/cron/crontabs/$(whoami) 2>/dev/null 1>/dev/null 0>/dev/null
        sudo sed -i '/umount/d' /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null
        sudo sed -i '/mount/d' /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null
        ctrl_c
        ;;

    9)  #desistalar el script
        #si se selecciona esta opcion se desistala el script y se elimina toda la configuracion
        clear
        echo -e ""
        echo -e "${verde} Desmontando unidades.${borra_colores}"
        echo -e ""
        for unidad in $carpetas
        do
            if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
            then
                sudo umount /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
                echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} desmontada correctamente."
                sleep 2
            else
                echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada. Imposible desmontar."
                sleep 2
            fi
            done
        clear
        echo -e ""
        echo -e "${amarillo} - Se borra fichero de configuracion.${borra_colores}"
        echo -e "${amarillo} - Se borraran las carpetas incluidas en: /home/$(whoami)/servidor_samba/${borra_colores}"
        echo -e "${amarillo} - Y se desistalara el script. Siempre que se haya instalado con un deb.${borra_colores}"
        echo -e ""
        echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
        read pause

        sudo rm /home/$(whoami)/.config/montar_unidades_automatico 2>/dev/null 1>/dev/null 0>/dev/null
        sudo rm -r /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
        sudo rm /home/$(whoami)/.config/config_montar_unidades 2>/dev/null 1>/dev/null 0>/dev/null
        sudo rm -r /home/$(whoami)/Escritorio/Unidades_automaticas.desktop 2>/dev/null 1>/dev/null 0>/dev/null
        sudo sed -i '/montar_unidades_automatico/d' /var/spool/cron/crontabs/$(whoami) 2>/dev/null 1>/dev/null 0>/dev/null
        sudo sed -i '/umount/d' /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null
        sudo sed -i '/mount/d' /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null
        sudo apt --purge remove montar-unidades -y
        ctrl_c
        ;;

    90) #ayuda
        clear
        echo -e "${rojo}   - Menu Ayuda -${borra_colores}"
        echo -e ""
        echo -e "${verde}   Este script lo que hace, es automatizar el proceso de montar unidades en tu distro de linux, escanea tu red y busca servidores de archivos que utilizan el protocolo SAMBA.${borra_colores}"
        echo -e "${verde}   Te muestra las carpetas compartidas y registra tus datos de acceso para poder montarlas de forma automatica.${borra_colores}"
        echo -e "${verde}   La primera vez que ejecutas el script, te pedira los datos necesarios para su configuracion.${borra_colores}"
        echo -e "${verde}   Las siguientes veces que ejecutes el script, las montara automaticamente sin pedirte nada, hay una parte en la que te pide que pulses (enter) y podras entrar al menu.${borra_colores}"
        echo -e ""
        echo -e "${amarillo}   Las opciones del menu son las siguientes:${borra_colores}"
        echo -e ""
        echo -e "   0.${azul} Actualizar el script.${borra_colores}"
        echo -e "       Pues esta claro, se actualiza el script si fuera necesario, para aplicar las mejoras del mismo."
        echo -e "   1.${azul} Ver/editar fichero de configuracion.${borra_colores}"
        echo -e "       Esta opcion es simple, carga en el editor nano el fichero de configuracion, en el estan todos los datos de conexion a tu servidor o servidores de ficheros SAMBA."
        echo -e "       Puedes modificar los datos de forma manual, como la direccion ip del servidor, los datos de usuario y password asi como las carpetas a las cuales quieres conectar."
        echo -e "       Nota. las carpetas o unidades de tu servidor, puedes poner tantas como quieras o tengas en tu servidor en una unica linea y separada por espacios"
        echo -e "           Ejemplo. ( datos1 datos2 videos fotos etc )"
        echo -e "   2.${azul} Ver direcciones ip de tu red.${borra_colores}"
        echo -e "       Con esta opcion podras ver todas las ips que tienes en tu red activas."
        echo -e "   3.${azul} Ver las carpetas compartidas de tu servidor.${borra_colores}"
        echo -e "       Simple, te muestra las carpetas que tienes disponibles en tu servidor SAMBA."
        echo -e "   4.${azul} Resetear toda la configuracion.${borra_colores}"
        echo -e "       Te permite dejar el script como recien instalado o descargado, borrara el fichero de configuracion, borrara el fichero de carga automatica si es que has configurado"
        echo -e "       la opcion 7 del menu, asi como eliminara las lineas del (crontab) y de (sudoers). Vamos lo deja limpio y cuando lo ejecutes tendras que volver a configurar."
        echo -e "   5.${azul} Montar las unidades.${borra_colores}"
        echo -e "       Facil. si has parado el inicio automatico del script para sacar el menu y realizar alguna modificacion, con esta opcion montaras las unidames o carpetas configuradas."
        echo -e "   6.${azul} Desmontar todas las unidades.${borra_colores}"
        echo -e "       Basicamente igual que la opcion 5, pero al reves, lo que hace es desmontar todo lo que tengas montado."
        echo -e "       De todas formas, al estar montadas con mount, si reinicias el equipo, NO se montaran, a no ser que lo tengas configurago con la opcion 7 del menu."
        echo -e "   7.${azul} Montar las unidades al inicio del sistema. (crontab).${borra_colores}"
        echo -e "       Con esta opcion, consigues que no tengas que ejecutar el script para montar las unidades o carpetas que tengas configuradas."
        echo -e "       Se crea una orden el el fichero (crontab) que se encarga de montar las unidades o carpetas de tu servidor automaticamente en cada reinicio de tu sistema y tu usuario."
        echo -e "       Hay que tener en cuenta que si lo tienes configurado con una lista de carpetas y un servisor y lo modificas manualmente, esos cambios no se modifican en el inicio del"
        echo -e "       sistema, una vez que los cambios esten realizados, tendras que seleccionar la opcion 7 del menu para que lo actualize."
        echo -e "   8.${azul} Eliminar toda la configuracion.${borra_colores}"
        echo -e "       Como su nombre dice, se elimina toda la configuracion que tengas activa, asi como los ficheros de montaje automatico de la opcion 7."
        echo -e "   9.${azul} Desistalar el script.${borra_colores}"
        echo -e "       Tambien como su nombre dice, se elimina toda la configuracion activa, asi asi como los ficheros de montaje automatico y se procede a la desistalacion."
        echo -e "  90.${azul} Ayuda.${borra_colores}"
        echo -e "       JeJe, lo que estas biendo."
        echo -e "  99.${azul} Atras / Salir.${borra_colores}"
        echo -e "       Muy simple, no hace falta decir nada."
        echo -e ""
        echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
        read pasue
        ;;

    99) #salir
        ctrl_c
        ;;

    *)  #se activa cuando se introduce una opcion no controlada del menu
        echo "";
        echo -e " ${amarillo}OPCION NO DISPONIBLE EN EL MENU.    Seleccion 0.1, 2, 3, 4, 5, 6, 90 o 99 ${borra_colores}";
        echo -e " ${amarillo}PRESIONA ENTER PARA CONTINUAR ........${borra_colores}";
        echo "";
        read pause;
        ;;
esac
done
}
#fin de funcion menu principal


#funcion de configuracion
#fichero configuracion en /home/usuario/.config/config_montar_unidades
function configuracion()
 {
wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz 2>/dev/null 1>/dev/null 0>/dev/null
#elimina /home/$(whoami)/.config/montar_unidades_automatico
rm /home/$(whoami)/.config/montar_unidades_automatico 2>/dev/null 1>/dev/null 0>/dev/null

#elimina linea de @reboot de crontab
crontab -u $(whoami) -l | grep -v "@reboot bash /home/$(whoami)/.config/montar_unidades_automatico"  | crontab -u $(whoami) - 2>/dev/null 1>/dev/null 0>/dev/null

#elimina las lineas en /etc/sudoers (sudo visudo)
sudo sed -i "/$(whoami) ALL=(ALL) NOPASSWD:/d" /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null

#elimina linea de @reboot de crontab
#crontab -u $(whoami) -l | grep -v "@reboot bash /home/$(whoami)/.config/montar_unidades_automatico"  | crontab -u $(whoami) - 2>/dev/null 1>/dev/null 0>/dev/null

clear
echo -e ""
echo -e "${azul} Recojida de datos para configurar el script con tu Servidor Samba.${borra_colores}"
echo -e ""
ip=$(route -n | awk '{print $2}' | grep 192) #saca la ip de la puerta de enlace
echo -e "${verde} Buscando direcciones ip donde estara tu servidor samba."
echo -e "${verde} Si no encuentra, la puedes introducir a mano."
echo -e ""

if [ $ip = "192.168.1.1" ] 2>/dev/null 1>/dev/null 0>/dev/null
then
    ip=192.168.1.0/24
else
    ip=192.168.0.0/24
fi

servidor_samba=$(sudo nmap --open -p 443 $ip | grep 192 | awk '{print $5}' | sed 's/_gateway/ /') 2>/dev/null 1>/dev/null 0>/dev/null
if [ -z $servidor_samba ] 2>/dev/null 1>/dev/null 0>/dev/null
then
    echo -e "${amarillo} No se ha encontrado servidor samba, por puerto 443.${borra_colores}"
    echo -e "${amarillo} Si te sabes la direccion, Introducela.${borra_colores}"
    echo -e ""
else
    sudo nmap --open -p 443 $ip | grep 192 | awk '{print "     " $5}' | sed 's/_gateway/ /'
    echo -e "${borra_colores}"
fi

read -p " Direccion ip del servidor samba ? -->> " ip_servidor_samba
read -p " Nombre de usuario del servidor samba ? -->> " usuario_servidor_samba
read -s -p " Password del servidor samba ? (No se mostrara) -->> " password_servidor_samba
echo -e ""


if smbclient -L //$ip_servidor_samba/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
then
    echo -e "\n ${azul}Listado de carpetas compartidas del servidor samba ($ip_servidor_samba).${borra_colores}"
    echo -e "${verde}"
    smbclient -L //$ip_servidor_samba/ -U=$usuario_servidor_samba%$password_servidor_samba | grep Disk | awk '{print "     " $1}'
    echo -e "${borra_colores}"
else
    echo -e ""
    echo -e "${amarillo} No se ha podido conectar al  servidor samba ($ip_servidor_samba), por puerto 443.${borra_colores}"
    echo -e "${amarillo} Ejecuta de nuevo el script.${borra_colores}"
    echo -e ""
    echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
    read pasue
    wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz 2>/dev/null 1>/dev/null 0>/dev/null
    exit
fi

read -p " Dime la carpeta que deseas del servidor samba, separadas por espacios -->> " carpetas
echo -e ""
for unidad in $carpetas
do
    if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
    then
        echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} correcto."
        sleep 2
        correcto=si
    else
        echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} No encontrada"
        sleep 2
        correcto=no
    fi
done

if [ $correcto = "si" ]
then
    echo -e ""
    echo -e "${verde} Carpetas seleccionadas correctamente.${borra_colores}"
    echo -e ""
    echo -e "${verde} Creando fichero de configuracion...${borra_colores}"
    rm /home/$(whoami)/.config/config_montar_unidades 2>/dev/null 1>/dev/null 0>/dev/null
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "# INDICA SI ESTA CONFIGURADO, OPCIONES (si,no) defecto (no)" >> /home/$(whoami)/.config/config_montar_unidades
    echo "# PONER EN (si) CUANDO LO TENGAS CONFIGURADO." >> /home/$(whoami)/.config/config_montar_unidades
    echo "configurado=si" >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "# INDICA LOS DATOS DE TU SERVIDOR." >> /home/$(whoami)/.config/config_montar_unidades
    echo "ip_servidor_samba=$ip_servidor_samba" >> /home/$(whoami)/.config/config_montar_unidades
    echo "usuario_servidor_samba=$usuario_servidor_samba" >> /home/$(whoami)/.config/config_montar_unidades
    echo "password_servidor_samba=$password_servidor_samba" >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "# INDICA LOS NOMBRE DE LAS CARPETAS A MONTAR SEPARADAS POR ESPACIO. #" >> /home/$(whoami)/.config/config_montar_unidades
    echo "carpetas='$carpetas'" >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "" >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    echo "# GRABA LOS CAMBION Y LISTO." >> /home/$(whoami)/.config/config_montar_unidades
    echo "# ACUERDATE DE PONER si EN LA PRIMERA OPCION." >> /home/$(whoami)/.config/config_montar_unidades
    echo "#####################################################################" >> /home/$(whoami)/.config/config_montar_unidades
    source /home/$(whoami)/.config/config_montar_unidades
    sleep 2
    echo -e ""
    echo -e " [${verde}ok${borra_colores}] Fichero de configuracion."
    sleep 2
else
    echo -e ""
    echo -e "${amarillo} Conexion a las carpetas a fallado.${borra_colores}"
    echo -e "${amarillo} Ejecuta de nuevo el script.${borra_colores}"
    echo -e ""
    echo -e "${azul} Pulsa una tecla para continuar.${borra_colores}"
    read pasue
    wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz 2>/dev/null 1>/dev/null 0>/dev/null
    exit
fi

}
#fin de funcion configuracion

#verifica software necesario
clear
echo -e ""
echo -e "${verde} Verificando software necesario.${borra_colores}"
echo -e ""
## Vericica conexion a internet
    if ping -c1 google.com &>/dev/null;
    then
        echo -e " [${verde}ok${borra_colores}] Conexion a internet."
        conexion="si" #sabemos si tenemos conexion a internet o no
    else
        echo -e " [${rojo}XX${borra_colores}] Conexion a internet."
        conexion="no" #sabemos si tenemos conexion a internet o no
    fi

for paquete in net-tools figlet smbclient wmctrl git nano cifs-utils nmap diff xdotool #ponemos el fostware a instalar separado por espacios
do
    which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa llamado programa
    sino=$? #recojemos el 0 o 1 del resultado de which
    contador="1" #ponemos la variable contador a 1
    while [ $sino -gt 0 ] #entra en el bicle si variable programa es 0, no lo ha encontrado which
    do
        if [ $contador = "4" ] #si el contador es 4 entre en then y sino en else
        then #si entra en then es porque el contador es igual a 4 y no ha podido instalar o no hay conexion a internet
            echo ""
            echo -e " ${amarillo}NO se ha podido instalar ($paquete).${borra_colores}"
            echo -e " ${amarillo}Intentelo usted con la orden:${borra_colores}"
            echo -e " ${rojo}-- sudo apt install $paquete --${borra_colores}"
            echo -e ""
            echo -e " ${rojo}No se puede ejecutar el script.${borra_colores}"
            echo ""
            exit
        else #intenta instalar
            if [ $paquete = "cifs-utils" ]
            then
                which cifscreds 2>/dev/null 1>/dev/null 0>/dev/null
                cifscreds=$?
                if [ $cifscreds = "0" ]
                then
                    break
                else
                    echo " Instalando $paquete. Intento $contador/3."
                    sudo apt install $paquete -y 2>/dev/null 1>/dev/null 0>/dev/null
                    let "contador=contador+1" #incrementa la variable contador en 1
                    which cifscreds 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa en tu sistema
                    sino=$? ##recojemos el 0 o 1 del resultado de which
                fi
            else
                echo -e ""
            fi

            if [ $paquete = "net-tools" ]
            then
                which arp 2>/dev/null 1>/dev/null 0>/dev/null
                arp=$?
                if [ $arp = "0" ]
                then
                    break
                else
                    echo " Instalando $paquete. Intento $contador/3."
                    sudo apt install $paquete -y 2>/dev/null 1>/dev/null 0>/dev/null
                    let "contador=contador+1" #incrementa la variable contador en 1
                    which arp 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa en tu sistema
                    sino=$? ##recojemos el 0 o 1 del resultado de which
                fi
            else
                echo -e ""
            fi

            echo " Instalando $paquete. Intento $contador/3."
            sudo apt install $paquete -y 2>/dev/null 1>/dev/null 0>/dev/null
            let "contador=contador+1" #incrementa la variable contador en 1
            which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa en tu sistema
            sino=$? ##recojemos el 0 o 1 del resultado de which
        fi
done
    echo -e " [${verde}ok${borra_colores}] $paquete."

done


#comprueba aztualiczacion del script

archivo_local="montar_unidades.sh" # Nombre del archivo local
ruta_repositorio="https://github.com/sukigsx/montar_unidades.git" #ruta del repositorio para actualizar y clonar con git clone

# Obtener la ruta del script
descarga=$(dirname "$(readlink -f "$0")")


git clone $ruta_repositorio /tmp/comprobar >/dev/null 2>&1

diff $descarga/$archivo_local /tmp/comprobar/$archivo_local >/dev/null 2>&1


if [ $? = 0 ]
then
    #esta actualizado, solo lo comprueba
    echo ""
    echo -e "${verde} El script${borra_colores} $0 ${verde}esta actualizado.${borra_colores}"
    echo ""
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    actualizado="si"
else
    #hay que actualizar, comprueba y actualiza
    echo ""
    echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
    echo -e "${verde} Opcion 0 del menu para actualizar.${borra_colores}"
    sleep 3
    actualizado="no"
fi




echo -e ""
echo -e "${verde} Continuamos...${borra_colores}"
sleep 2
#Fin de verifica software necesario

#comprobando si el fichero de configuracion esta configurado
source /home/$(whoami)/.config/config_montar_unidades 2>/dev/null 1>/dev/null 0>/dev/null
if [ $configurado = "si" ] 2>/dev/null 1>/dev/null 0>/dev/null
then
    #si es que si, espera el tiempo por si quieres entrar al menu, pasado el tiempo monta las unidades configuradas.
    echo -e "${amarillo} Se montaran las unidades automaticamente.${borra_colores}"
    echo -e "${amarillo} De lo contrario pulsa Enter, para entrar al menu.${borra_colores}"
    if read -t 5 -p "" name
    then
        #muestra el menu
        menu
    else
        #no muestra el menu pasado el tiempo y monta las unidades del fichero de configuracion
        clear
        echo -e ""
        echo -e "${verde} Montando las unidades.${borra_colores}"
        echo -e ""
        for unidad in $carpetas
        do
            if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
            then
                mkdir /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
                mkdir /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
                sudo mount -t cifs  //$ip_servidor_samba/$unidad /home/$(whoami)/servidor_samba/$unidad -o user=$usuario_servidor_samba,password=$password_servidor_samba,uid=$usuario_servidor_samba,gid=$usuario_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
                echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} montada correctamente."
                sleep 2
            else
                echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada."
                sleep 2
            fi
        done
        ctrl_c
    fi
else
    configuracion
    clear
    echo -e ""
    echo -e "${verde} Montando las unidades.${borra_colores}"
    echo -e ""
    for unidad in $carpetas
    do
        if smbclient -c ls //$ip_servidor_samba/$unidad/ -U=$usuario_servidor_samba%$password_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null #comprueba que exista la unudad
        then
            mkdir /home/$(whoami)/servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
            mkdir /home/$(whoami)/servidor_samba/$unidad 2>/dev/null 1>/dev/null 0>/dev/null
            sudo mount -t cifs  //$ip_servidor_samba/$unidad /home/$(whoami)/servidor_samba/$unidad -o user=$usuario_servidor_samba,password=$password_servidor_samba,uid=$usuario_servidor_samba,gid=$usuario_servidor_samba 2>/dev/null 1>/dev/null 0>/dev/null
            echo -e " [${verde}V${borra_colores}] Unidad ${verde}$unidad${borra_colores} montada correctamente."
            sleep 2
        else
            echo -e " [${rojo}X${borra_colores}] Unidad ${rojo}$unidad${borra_colores} NO montada."
            sleep 2
        fi
    done
    ctrl_c
fi
#fin comprobacion si el fichero de configuracion esta configurado
