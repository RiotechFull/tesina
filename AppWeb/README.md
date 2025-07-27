# Sistema de Gestión de Asistencia Técnica

Un sistema web completo para la gestión de asistencia técnica de hardware para clientes, desarrollado con Python Flask y MySQL.

## 🚀 Características

### Dashboard Principal
- **Estadísticas en tiempo real**: Total de tickets, pendientes, completados y clientes activos
- **Tickets recientes**: Vista rápida de los últimos tickets creados
- **Actividad reciente**: Seguimiento de las últimas acciones del sistema
- **Gráficos interactivos**: Visualización de datos con Chart.js

### Gestión de Tickets
- **Crear tickets**: Formulario completo para nuevos tickets de soporte
- **Filtros avanzados**: Por estado, prioridad, técnico y búsqueda de texto
- **Estados de tickets**: Abierto, En Proceso, Esperando Cliente, Cerrado
- **Prioridades**: Baja, Media, Alta, Urgente
- **Asignación de técnicos**: Asignar tickets a técnicos específicos
- **Seguimiento completo**: Historial de cambios y actualizaciones

### Gestión de Clientes
- **Registro de clientes**: Información completa de contacto
- **Historial de tickets**: Seguimiento de todos los tickets por cliente
- **Estadísticas por cliente**: Total de tickets y tickets activos
- **Gestión de empresas**: Asociar clientes a empresas

### Inventario de Hardware
- **Categorización**: Computadoras, Impresoras, Equipos de Red, Periféricos, Servidores
- **Números de serie**: Control único de cada equipo
- **Estados de equipos**: Funcionando, En Mantenimiento, En Reparación, Retirado
- **Relación con tickets**: Vincular tickets a equipos específicos

### Reportes y Estadísticas
- **Tickets por estado**: Gráfico de dona con distribución de estados
- **Tickets por mes**: Gráfico de línea con tendencias temporales
- **Rendimiento de técnicos**: Gráfico de barras con tickets completados
- **Tipos de hardware**: Gráfico circular con distribución de categorías

### Sistema de Usuarios
- **Roles de usuario**: Administrador, Técnico, Gerente, Soporte
- **Autenticación segura**: Login con hash de contraseñas
- **Sesiones persistentes**: Opción "Recordarme"
- **Control de acceso**: Rutas protegidas por rol

## 🛠️ Tecnologías Utilizadas

### Backend
- **Python 3.8+**: Lenguaje principal
- **Flask 2.3.3**: Framework web
- **Flask-SQLAlchemy**: ORM para base de datos
- **Flask-Login**: Gestión de sesiones de usuario
- **Werkzeug**: Utilidades web (hash de contraseñas)

### Base de Datos
- **MySQL**: Base de datos principal
- **PyMySQL**: Conector Python para MySQL

### Frontend
- **HTML5**: Estructura semántica
- **CSS3**: Estilos modernos y responsivos
- **JavaScript ES6+**: Interactividad y AJAX
- **Chart.js**: Gráficos interactivos
- **Font Awesome**: Iconografía
- **Google Fonts (Inter)**: Tipografía moderna

### Características de Diseño
- **Responsive Design**: Compatible con móviles y tablets
- **Material Design**: Principios de diseño moderno
- **Animaciones CSS**: Transiciones suaves
- **Modo oscuro**: Preparado para futuras implementaciones

## 📋 Requisitos del Sistema

### Software Requerido
- Python 3.8 o superior
- MySQL 5.7 o superior
- pip (gestor de paquetes de Python)

### Dependencias del Sistema
- Windows: Visual C++ Build Tools
- Linux: python3-dev, libmysqlclient-dev
- macOS: Xcode Command Line Tools

## 🔧 Instalación

### 1. Clonar el Repositorio
```bash
git clone <url-del-repositorio>
cd AppWeb
```

### 2. Crear Entorno Virtual
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/macOS
python3 -m venv venv
source venv/bin/activate
```

### 3. Instalar Dependencias
```bash
pip install -r requirements.txt
```

### 4. Configurar Base de Datos MySQL

#### Crear Base de Datos
```sql
CREATE DATABASE techsupport_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'techsupport_user'@'localhost' IDENTIFIED BY 'tu_contraseña_segura';
GRANT ALL PRIVILEGES ON techsupport_db.* TO 'techsupport_user'@'localhost';
FLUSH PRIVILEGES;
```

#### Configurar Conexión
Editar el archivo `app.py` y actualizar la configuración de la base de datos:

```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://techsupport_user:tu_contraseña_segura@localhost/techsupport_db'
```

### 5. Configurar Variables de Entorno
Crear archivo `.env` en la raíz del proyecto:

```env
SECRET_KEY=tu_clave_secreta_muy_segura_aqui
DATABASE_URL=mysql://techsupport_user:tu_contraseña_segura@localhost/techsupport_db
FLASK_ENV=development
```

### 6. Inicializar Base de Datos
```bash
python app.py
```

La aplicación creará automáticamente las tablas necesarias en la base de datos.

### 7. Ejecutar la Aplicación
```bash
python app.py
```

La aplicación estará disponible en `http://localhost:5000`

## 👤 Primeros Pasos

### 1. Crear Usuario Administrador
La primera vez que ejecutes la aplicación, necesitarás crear un usuario administrador:

1. Ve a `http://localhost:5000/register`
2. Completa el formulario de registro
3. Selecciona el rol "Administrador"
4. Inicia sesión con las credenciales creadas

### 2. Configuración Inicial
1. **Agregar Clientes**: Ve a la sección "Clientes" y agrega algunos clientes de prueba
2. **Registrar Hardware**: En "Inventario", agrega equipos de hardware
3. **Crear Tickets**: Comienza a crear tickets de soporte técnico

## 📁 Estructura del Proyecto

```
AppWeb/
├── app.py                 # Aplicación principal Flask
├── requirements.txt       # Dependencias de Python
├── README.md             # Este archivo
├── .env                  # Variables de entorno (crear)
├── Static/               # Archivos estáticos
│   ├── styles.css        # Estilos CSS principales
│   └── scripts.js        # JavaScript del frontend
└── templates/            # Plantillas HTML
    ├── index.html        # Dashboard principal
    ├── login.html        # Página de login
    └── registro.html     # Página de registro
```

## 🔐 Seguridad

### Características de Seguridad Implementadas
- **Hash de contraseñas**: Uso de Werkzeug para hash seguro
- **Sesiones seguras**: Flask-Login para gestión de sesiones
- **Protección CSRF**: Preparado para implementar tokens CSRF
- **Validación de entrada**: Validación tanto en frontend como backend
- **Control de acceso**: Rutas protegidas por autenticación

### Recomendaciones de Seguridad
1. **Cambiar la clave secreta**: Modificar `SECRET_KEY` en producción
2. **Usar HTTPS**: Configurar SSL/TLS en producción
3. **Backup regular**: Realizar copias de seguridad de la base de datos
4. **Actualizaciones**: Mantener dependencias actualizadas
5. **Firewall**: Configurar firewall del servidor

## 🚀 Despliegue en Producción

### Usando Gunicorn
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 app:app
```

### Usando uWSGI
```bash
pip install uwsgi
uwsgi --socket 0.0.0.0:8000 --protocol=http -w app:app
```

### Configuración de Nginx
```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /static {
        alias /ruta/a/tu/proyecto/Static;
    }
}
```

## 🔧 Configuración Avanzada

### Variables de Entorno Adicionales
```env
# Configuración de correo (para futuras funcionalidades)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-contraseña-de-aplicación

# Configuración de logging
LOG_LEVEL=INFO
LOG_FILE=app.log
```

### Personalización de Estilos
Los estilos se pueden personalizar editando `Static/styles.css`. El sistema utiliza:
- **Variables CSS**: Para colores y espaciados consistentes
- **Flexbox y Grid**: Para layouts responsivos
- **CSS Custom Properties**: Para temas dinámicos

## 📊 API REST

La aplicación incluye una API REST completa para integración con otros sistemas:

### Endpoints Principales
- `GET /api/tickets` - Listar tickets
- `POST /api/tickets` - Crear ticket
- `GET /api/tickets/<id>` - Obtener ticket específico
- `PUT /api/tickets/<id>` - Actualizar ticket
- `DELETE /api/tickets/<id>` - Eliminar ticket

- `GET /api/clients` - Listar clientes
- `POST /api/clients` - Crear cliente
- `GET /api/clients/<id>` - Obtener cliente específico
- `PUT /api/clients/<id>` - Actualizar cliente

- `GET /api/inventory` - Listar inventario
- `POST /api/inventory` - Crear item
- `GET /api/inventory/<id>` - Obtener item específico
- `PUT /api/inventory/<id>` - Actualizar item

## 🐛 Solución de Problemas

### Problemas Comunes

#### Error de Conexión a MySQL
```
Error: (2003, "Can't connect to MySQL server")
```
**Solución**: Verificar que MySQL esté ejecutándose y las credenciales sean correctas.

#### Error de Módulos Python
```
ModuleNotFoundError: No module named 'flask'
```
**Solución**: Activar el entorno virtual e instalar dependencias:
```bash
source venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
```

#### Error de Permisos de Base de Datos
```
Access denied for user 'techsupport_user'@'localhost'
```
**Solución**: Verificar permisos del usuario MySQL:
```sql
GRANT ALL PRIVILEGES ON techsupport_db.* TO 'techsupport_user'@'localhost';
FLUSH PRIVILEGES;
```

## 🤝 Contribuciones

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:
- Crear un issue en el repositorio
- Contactar al equipo de desarrollo
- Revisar la documentación de Flask y MySQL

## 🔄 Actualizaciones

### Versión 1.0.0
- Sistema básico de gestión de tickets
- Gestión de clientes e inventario
- Dashboard con estadísticas
- Sistema de autenticación
- API REST completa

### Próximas Versiones
- Notificaciones por email
- Reportes avanzados
- Integración con sistemas externos
- Aplicación móvil
- Modo oscuro
- Multiidioma

---

**Desarrollado con ❤️ para la gestión eficiente de asistencia técnica** 