Este script de Bash es un programa interactivo que proporciona una interfaz de usuario para configurar y gestionar el montaje automático de unidades compartidas de un servidor Samba en un sistema Linux. A continuación, se describen las principales funcionalidades del script:

1. **Actualización del Script:**
   - Descarga la versión más reciente del script desde un repositorio de GitHub y actualiza el script local si es necesario.

2. **Ver/Editar Fichero de Configuración:**
   - Permite ver y editar el fichero de configuración que contiene los detalles de la conexión al servidor Samba.

3. **Ver Direcciones IP de Tu Red:**
   - Muestra una lista de direcciones IP de dispositivos en la misma red local.

4. **Ver Carpetas Compartidas del Servidor:**
   - Muestra una lista de las carpetas compartidas en el servidor Samba especificado en el fichero de configuración.

5. **Configurar de Nuevo las Unidades a Montar:**
   - Desmonta las unidades existentes y permite configurar nuevas unidades compartidas para montar.

6. **Montar las Unidades:**
   - Monta las unidades compartidas del servidor Samba en el sistema local.

7. **Desmontar Todas las Unidades:**
   - Desmonta todas las unidades previamente montadas.

8. **Montar las Unidades al Inicio del Sistema (con Crontab):**
   - Configura el montaje automático de las unidades al inicio del sistema mediante Crontab. Crea un fichero de script y un acceso directo en el escritorio para este propósito.

9. **Eliminar Toda la Configuración:**
   - Desmonta las unidades, elimina carpetas y ficheros de configuración, y revierte las modificaciones hechas en Crontab y sudoers.

10. **Desinstalar el Script:**
    - Elimina el script y toda la configuración del sistema.

El script interactúa con el usuario a través de un menú de selección numérica y realiza diversas acciones según la opción seleccionada por el usuario. Además, verifica la disponibilidad de las unidades compartidas y valida la configuración del usuario antes de realizar acciones como montar o desmontar unidades.

Por favor, ten en cuenta que este script asume que el usuario tiene permisos adecuados para ejecutar comandos sudo y realizar operaciones de montaje y desmontaje en el sistema.


# Funcionamiento de la instalacion

Este script de Bash realiza una serie de operaciones para configurar un servidor Samba en un sistema Linux. Vamos a desglosar su funcionamiento por partes:

1. **Inicio del script:**
   - `wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz 2>/dev/null 1>/dev/null 0>/dev/null`: Intenta maximizar la ventana actual, ocultando posibles errores de salida (stderr, stdout y errores estándar).

   - `rm /home/$(whoami)/.config/montar_unidades_automatico 2>/dev/null 1>/dev/null 0>/dev/null`: Elimina el archivo `montar_unidades_automatico` en la ruta específica del usuario actual.

   - `crontab -u $(whoami) -l | grep -v "@reboot bash /home/$(whoami)/.config/montar_unidades_automatico"  | crontab -u $(whoami) - 2>/dev/null 1>/dev/null 0>/dev/null`: Elimina la línea que contiene el comando de reinicio automático del script en el crontab del usuario actual.

   - `sudo sed -i "/$(whoami) ALL=(ALL) NOPASSWD:/d" /etc/sudoers 2>/dev/null 1>/dev/null 0>/dev/null`: Elimina la entrada que permite al usuario actual ejecutar comandos con sudo sin contraseña.

2. **Recopilación de datos:**
   - El script utiliza `route -n` y `nmap` para encontrar la dirección IP del servidor Samba en la red local.
   - Solicita al usuario la dirección IP del servidor Samba, el nombre de usuario y la contraseña para acceder al servidor Samba.
   - Utiliza `smbclient` para listar las carpetas compartidas en el servidor Samba y permite al usuario seleccionar las carpetas que desea montar.

3. **Creación de un archivo de configuración:**
   - Crea un archivo de configuración en la ruta `/home/$(whoami)/.config/config_montar_unidades` con la información proporcionada por el usuario (dirección IP del servidor, nombre de usuario, contraseña y carpetas seleccionadas).

4. **Conclusión del script:**
   - El script imprime mensajes en color indicando el progreso y el estado del proceso.
   - En caso de éxito, muestra un mensaje indicando que las carpetas se han configurado correctamente y crea el archivo de configuración.
   - Si hay un problema en cualquier etapa, muestra un mensaje de error y termina el script.

**Notas:**
- Las líneas que contienen `2>/dev/null 1>/dev/null 0>/dev/null` se utilizan para redirigir los errores estándar (stderr) y la salida estándar (stdout) a un archivo nulo, lo que significa que los mensajes de error y salida se descartan y no se muestran al usuario.
- Algunas operaciones, como la eliminación de archivos y la modificación de configuraciones sensibles (como sudoers), requieren privilegios elevados, por lo que se utilizan comandos `sudo` para ejecutar estas operaciones con permisos de superusuario.

# Software necesario y Actualizaciones

Este script de shell tiene como objetivo verificar la presencia de ciertos programas en un sistema y, si no están presentes, intenta instalarlos automáticamente. Luego, comprueba si el script local está actualizado comparándolo con una versión en un repositorio de GitHub. Aquí está el desglose del funcionamiento del script:

### Verificación de Conexión a Internet
- Utiliza el comando `ping` para verificar la conexión a internet. Si la conexión está activa, establece la variable `conexion` a "si"; de lo contrario, se establece en "no".

### Instalación de Programas Necesarios
- Utiliza un bucle `for` para iterar sobre una lista de programas (`net-tools`, `figlet`, `smbclient`, etc.) y verifica si están instalados en el sistema usando el comando `which`.
- Si un programa no está instalado, intenta instalarlo usando `sudo apt install` hasta 3 intentos. Algunos programas tienen comprobaciones adicionales antes de la instalación (por ejemplo, `cifs-utils` y `net-tools`).

### Verificación y Actualización del Script Local
- Clona el script desde un repositorio de GitHub en un directorio temporal `/tmp/comprobar`.
- Compara el script local con la versión del repositorio usando el comando `diff`.
- Si los scripts son idénticos (`diff` retorna 0), muestra un mensaje indicando que el script está actualizado y elimina el directorio temporal.
- Si hay diferencias (`diff` no retorna 0), muestra un mensaje indicando que el script no está actualizado y sugiere utilizar la opción 0 del menú para actualizar.

# Instalacion
- Clonar el repositorio con la orden (git clone https://github.com/sukigsx/montar_unidades.git)

## ¡ Espero os guste !
