-- =====================================================
-- SISTEMA DE GESTIÓN DE ASISTENCIA TÉCNICA
-- Base de datos MySQL para TechSupport Pro
-- =====================================================

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS techsupport_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE techsupport_db;

-- =====================================================
-- TABLA DE USUARIOS
-- =====================================================
CREATE TABLE IF NOT EXISTS user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'technician',
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE CLIENTES
-- =====================================================
CREATE TABLE IF NOT EXISTS client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_company (company)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE HARDWARE/INVENTARIO
-- =====================================================
CREATE TABLE IF NOT EXISTS hardware (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'funcionando',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_serial_number (serial_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE TICKETS
-- =====================================================
CREATE TABLE IF NOT EXISTS ticket (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'abierto',
    priority VARCHAR(20) DEFAULT 'media',
    client_id INT NOT NULL,
    technician_id INT,
    hardware_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client(id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES user(id) ON DELETE SET NULL,
    FOREIGN KEY (hardware_id) REFERENCES hardware(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_client_id (client_id),
    INDEX idx_technician_id (technician_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE COMENTARIOS DE TICKETS
-- =====================================================
CREATE TABLE IF NOT EXISTS ticket_comment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE HISTORIAL DE CAMBIOS
-- =====================================================
CREATE TABLE IF NOT EXISTS ticket_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERTAR DATOS DE EJEMPLO
-- =====================================================

-- Insertar usuarios de ejemplo
INSERT INTO user (first_name, last_name, email, phone, role, password_hash) VALUES
('Juan', 'Pérez', 'juan.perez@techsupport.com', '+34 600 123 456', 'admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2'),
('María', 'García', 'maria.garcia@techsupport.com', '+34 600 234 567', 'technician', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2'),
('Carlos', 'López', 'carlos.lopez@techsupport.com', '+34 600 345 678', 'technician', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2'),
('Ana', 'Martínez', 'ana.martinez@techsupport.com', '+34 600 456 789', 'manager', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2'),
('Luis', 'Rodríguez', 'luis.rodriguez@techsupport.com', '+34 600 567 890', 'support', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2');

-- Insertar clientes de ejemplo
INSERT INTO client (name, email, phone, company, address) VALUES
('Empresa ABC S.L.', 'contacto@empresaabc.com', '+34 900 111 222', 'Empresa ABC S.L.', 'Calle Mayor 123, 28001 Madrid'),
('Corporación XYZ', 'soporte@corporacionxyz.com', '+34 900 333 444', 'Corporación XYZ', 'Avenida Diagonal 456, 08013 Barcelona'),
('Startup Innovadora', 'tech@startupinnovadora.com', '+34 900 555 666', 'Startup Innovadora', 'Calle de la Innovación 789, 41001 Sevilla'),
('Consultora Digital', 'info@consultoradigital.com', '+34 900 777 888', 'Consultora Digital', 'Plaza Mayor 321, 46001 Valencia'),
('Fábrica Industrial', 'mantenimiento@fabrica.com', '+34 900 999 000', 'Fábrica Industrial', 'Polígono Industrial 654, 50001 Zaragoza'),
('Clínica Médica', 'sistemas@clinicamedica.com', '+34 900 111 333', 'Clínica Médica', 'Calle de la Salud 987, 29001 Málaga'),
('Universidad Pública', 'it@universidad.com', '+34 900 444 555', 'Universidad Pública', 'Campus Universitario 147, 18001 Granada'),
('Banco Nacional', 'soporte@bancosoporte.com', '+34 900 666 777', 'Banco Nacional', 'Plaza de la Banca 258, 48001 Bilbao');

-- Insertar hardware de ejemplo
INSERT INTO hardware (name, category, serial_number, status, description) VALUES
('Dell OptiPlex 7090', 'computadora', 'DELL-OP-7090-001', 'funcionando', 'Ordenador de escritorio Dell OptiPlex 7090 con Intel i7'),
('HP LaserJet Pro M404n', 'impresora', 'HP-LJ-M404N-001', 'funcionando', 'Impresora láser HP LaserJet Pro M404n'),
('Cisco Catalyst 2960', 'red', 'CISCO-CAT-2960-001', 'funcionando', 'Switch de red Cisco Catalyst 2960 24 puertos'),
('Teclado Logitech K780', 'periferico', 'LOG-K780-001', 'funcionando', 'Teclado inalámbrico Logitech K780'),
('Servidor Dell PowerEdge R740', 'servidor', 'DELL-PE-R740-001', 'funcionando', 'Servidor Dell PowerEdge R740 con 2 CPUs Xeon'),
('Monitor LG 27UL850', 'periferico', 'LG-27UL850-001', 'funcionando', 'Monitor LG 27" 4K Ultra HD'),
('Impresora Canon PIXMA TS8320', 'impresora', 'CANON-PIXMA-TS8320-001', 'mantenimiento', 'Impresora multifunción Canon PIXMA TS8320'),
('Switch HP ProCurve 2520', 'red', 'HP-PC-2520-001', 'funcionando', 'Switch HP ProCurve 2520 24 puertos'),
('Lenovo ThinkPad X1 Carbon', 'computadora', 'LENOVO-TP-X1C-001', 'reparacion', 'Portátil Lenovo ThinkPad X1 Carbon'),
('Servidor HP ProLiant DL380', 'servidor', 'HP-PL-DL380-001', 'funcionando', 'Servidor HP ProLiant DL380 Gen10'),
('Mouse Logitech MX Master 3', 'periferico', 'LOG-MX-M3-001', 'funcionando', 'Ratón inalámbrico Logitech MX Master 3'),
('Impresora Brother HL-L2350DW', 'impresora', 'BROTHER-HL-L2350DW-001', 'funcionando', 'Impresora láser Brother HL-L2350DW'),
('Router Cisco ISR 4321', 'red', 'CISCO-ISR-4321-001', 'funcionando', 'Router Cisco ISR 4321'),
('Dell Latitude 5520', 'computadora', 'DELL-LAT-5520-001', 'funcionando', 'Portátil Dell Latitude 5520'),
('Servidor IBM System x3650', 'servidor', 'IBM-SYS-X3650-001', 'retirado', 'Servidor IBM System x3650 M4');

-- Insertar tickets de ejemplo
INSERT INTO ticket (title, description, status, priority, client_id, technician_id, hardware_id) VALUES
('Problema con impresora HP', 'La impresora HP LaserJet no imprime correctamente. Aparecen líneas en las páginas.', 'abierto', 'media', 1, 2, 2),
('Servidor no responde', 'El servidor Dell PowerEdge no responde a las conexiones SSH. Necesita revisión urgente.', 'en_proceso', 'alta', 2, 3, 5),
('Switch de red caído', 'El switch Cisco Catalyst ha dejado de funcionar. Toda la red está caída.', 'abierto', 'urgente', 3, 2, 3),
('Teclado no funciona', 'El teclado Logitech K780 no responde. Posible problema de conectividad Bluetooth.', 'esperando_cliente', 'baja', 4, 4, 4),
('Monitor con manchas', 'El monitor LG presenta manchas en la pantalla. Posible problema de hardware.', 'cerrado', 'media', 5, 3, 6),
('Impresora Canon atascada', 'La impresora Canon PIXMA está atascada con papel. Necesita limpieza.', 'en_proceso', 'media', 6, 2, 7),
('Portátil Lenovo no arranca', 'El portátil Lenovo ThinkPad no arranca. Pantalla azul al iniciar.', 'abierto', 'alta', 7, 3, 9),
('Servidor HP con ruido', 'El servidor HP ProLiant hace mucho ruido. Posible problema con ventiladores.', 'abierto', 'media', 8, 2, 10),
('Mouse Logitech sin batería', 'El mouse Logitech MX Master no mantiene la carga. Batería defectuosa.', 'cerrado', 'baja', 1, 4, 11),
('Impresora Brother offline', 'La impresora Brother aparece como offline en la red. Problema de conectividad.', 'en_proceso', 'media', 2, 2, 12),
('Router Cisco sin internet', 'El router Cisco ISR no proporciona conexión a internet. Configuración incorrecta.', 'abierto', 'alta', 3, 3, 13),
('Portátil Dell lento', 'El portátil Dell Latitude funciona muy lento. Posible problema de malware.', 'esperando_cliente', 'media', 4, 4, 14),
('Servidor IBM obsoleto', 'El servidor IBM System x3650 es muy antiguo y necesita reemplazo.', 'cerrado', 'baja', 5, 2, 15),
('Switch HP con puertos muertos', 'Algunos puertos del switch HP ProCurve no funcionan. Necesita reemplazo.', 'abierto', 'alta', 6, 3, 8),
('Ordenador Dell con virus', 'El ordenador Dell OptiPlex tiene virus. Necesita limpieza y reinstalación.', 'en_proceso', 'alta', 7, 2, 1);

-- Insertar comentarios de ejemplo
INSERT INTO ticket_comment (ticket_id, user_id, comment) VALUES
(1, 2, 'He revisado la impresora y parece ser un problema con el cartucho de tóner. Necesito reemplazarlo.'),
(1, 1, 'Aprobado el reemplazo del cartucho. Proceder con la reparación.'),
(2, 3, 'El servidor está funcionando correctamente ahora. He reiniciado los servicios necesarios.'),
(3, 2, 'He verificado el switch y encontré un cable de red suelto. Ya está solucionado.'),
(4, 4, 'He contactado al cliente para confirmar si el problema persiste con el teclado.'),
(5, 3, 'El monitor ha sido reemplazado por uno nuevo. Ticket cerrado.'),
(6, 2, 'He limpiado la impresora y retirado el papel atascado. Funcionando correctamente.'),
(7, 3, 'El problema parece ser de hardware. Necesito más tiempo para diagnosticar.'),
(8, 2, 'He verificado los ventiladores del servidor. Funcionan correctamente.'),
(9, 4, 'He reemplazado la batería del mouse. Funcionando perfectamente.'),
(10, 2, 'He reiniciado la impresora y reconectado a la red. Ya está online.'),
(11, 3, 'He verificado la configuración del router. Problema resuelto.'),
(12, 4, 'He ejecutado un antivirus completo. El portátil ya funciona correctamente.'),
(13, 2, 'El servidor IBM ha sido reemplazado por uno nuevo. Ticket cerrado.'),
(14, 3, 'He verificado los puertos del switch. Algunos necesitan reemplazo.'),
(15, 2, 'He limpiado el virus del ordenador y reinstalado el sistema operativo.');

-- Insertar historial de cambios de ejemplo
INSERT INTO ticket_history (ticket_id, user_id, action, old_value, new_value) VALUES
(1, 2, 'status_change', 'abierto', 'en_proceso'),
(1, 1, 'priority_change', 'media', 'alta'),
(2, 3, 'status_change', 'abierto', 'en_proceso'),
(2, 3, 'status_change', 'en_proceso', 'cerrado'),
(3, 2, 'status_change', 'abierto', 'cerrado'),
(4, 4, 'status_change', 'abierto', 'esperando_cliente'),
(5, 3, 'status_change', 'en_proceso', 'cerrado'),
(6, 2, 'status_change', 'abierto', 'en_proceso'),
(7, 3, 'priority_change', 'media', 'alta'),
(8, 2, 'technician_assignment', NULL, 'María García'),
(9, 4, 'status_change', 'abierto', 'cerrado'),
(10, 2, 'status_change', 'abierto', 'en_proceso'),
(11, 3, 'priority_change', 'media', 'alta'),
(12, 4, 'status_change', 'abierto', 'esperando_cliente'),
(13, 2, 'status_change', 'abierto', 'cerrado'),
(14, 3, 'priority_change', 'media', 'alta'),
(15, 2, 'status_change', 'abierto', 'en_proceso');

-- =====================================================
-- CREAR VISTAS ÚTILES
-- =====================================================

-- Vista para estadísticas del dashboard
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT 
    COUNT(*) as total_tickets,
    SUM(CASE WHEN status != 'cerrado' THEN 1 ELSE 0 END) as pending_tickets,
    SUM(CASE WHEN status = 'cerrado' THEN 1 ELSE 0 END) as completed_tickets,
    COUNT(DISTINCT client_id) as total_clients
FROM ticket;

-- Vista para tickets con información completa
CREATE OR REPLACE VIEW ticket_details AS
SELECT 
    t.id,
    t.title,
    t.description,
    t.status,
    t.priority,
    t.created_at,
    t.updated_at,
    c.name as client_name,
    c.email as client_email,
    c.phone as client_phone,
    u.name as technician_name,
    h.name as hardware_name,
    h.serial_number as hardware_serial
FROM ticket t
LEFT JOIN client c ON t.client_id = c.id
LEFT JOIN user u ON t.technician_id = u.id
LEFT JOIN hardware h ON t.hardware_id = h.id;

-- Vista para estadísticas por técnico
CREATE OR REPLACE VIEW technician_stats AS
SELECT 
    u.id,
    u.name as technician_name,
    COUNT(t.id) as total_tickets,
    SUM(CASE WHEN t.status = 'cerrado' THEN 1 ELSE 0 END) as completed_tickets,
    AVG(CASE WHEN t.status = 'cerrado' THEN DATEDIFF(t.updated_at, t.created_at) END) as avg_resolution_days
FROM user u
LEFT JOIN ticket t ON u.id = t.technician_id
WHERE u.role IN ('technician', 'admin')
GROUP BY u.id, u.name;

-- Vista para estadísticas por cliente
CREATE OR REPLACE VIEW client_stats AS
SELECT 
    c.id,
    c.name as client_name,
    c.company,
    COUNT(t.id) as total_tickets,
    SUM(CASE WHEN t.status != 'cerrado' THEN 1 ELSE 0 END) as active_tickets,
    SUM(CASE WHEN t.status = 'cerrado' THEN 1 ELSE 0 END) as completed_tickets,
    MAX(t.created_at) as last_ticket_date
FROM client c
LEFT JOIN ticket t ON c.id = t.client_id
GROUP BY c.id, c.name, c.company;

-- =====================================================
-- CREAR PROCEDIMIENTOS ALMACENADOS
-- =====================================================

DELIMITER //

-- Procedimiento para obtener tickets por estado
CREATE PROCEDURE GetTicketsByStatus(IN ticket_status VARCHAR(20))
BEGIN
    SELECT 
        t.id,
        t.title,
        t.status,
        t.priority,
        c.name as client_name,
        u.name as technician_name,
        t.created_at
    FROM ticket t
    LEFT JOIN client c ON t.client_id = c.id
    LEFT JOIN user u ON t.technician_id = u.id
    WHERE t.status = ticket_status
    ORDER BY t.created_at DESC;
END //

-- Procedimiento para obtener estadísticas mensuales
CREATE PROCEDURE GetMonthlyStats(IN year_param INT)
BEGIN
    SELECT 
        MONTH(created_at) as month,
        COUNT(*) as total_tickets,
        SUM(CASE WHEN status = 'cerrado' THEN 1 ELSE 0 END) as completed_tickets,
        SUM(CASE WHEN status != 'cerrado' THEN 1 ELSE 0 END) as pending_tickets
    FROM ticket
    WHERE YEAR(created_at) = year_param
    GROUP BY MONTH(created_at)
    ORDER BY month;
END //

-- Procedimiento para asignar técnico a ticket
CREATE PROCEDURE AssignTechnicianToTicket(
    IN ticket_id_param INT,
    IN technician_id_param INT,
    IN user_id_param INT
)
BEGIN
    DECLARE current_technician INT;
    
    -- Obtener técnico actual
    SELECT technician_id INTO current_technician 
    FROM ticket WHERE id = ticket_id_param;
    
    -- Actualizar ticket
    UPDATE ticket 
    SET technician_id = technician_id_param,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = ticket_id_param;
    
    -- Registrar en historial
    INSERT INTO ticket_history (ticket_id, user_id, action, old_value, new_value)
    VALUES (ticket_id_param, user_id_param, 'technician_assignment', 
            (SELECT name FROM user WHERE id = current_technician),
            (SELECT name FROM user WHERE id = technician_id_param));
END //

DELIMITER ;

-- =====================================================
-- CREAR TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER update_ticket_timestamp
BEFORE UPDATE ON ticket
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

-- Trigger para registrar cambios de estado
CREATE TRIGGER ticket_status_change
AFTER UPDATE ON ticket
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO ticket_history (ticket_id, user_id, action, old_value, new_value)
        VALUES (NEW.id, NEW.technician_id, 'status_change', OLD.status, NEW.status);
    END IF;
    
    IF OLD.priority != NEW.priority THEN
        INSERT INTO ticket_history (ticket_id, user_id, action, old_value, new_value)
        VALUES (NEW.id, NEW.technician_id, 'priority_change', OLD.priority, NEW.priority);
    END IF;
END //

DELIMITER ;

-- =====================================================
-- CREAR ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_ticket_status_priority ON ticket(status, priority);
CREATE INDEX idx_ticket_client_status ON ticket(client_id, status);
CREATE INDEX idx_ticket_technician_status ON ticket(technician_id, status);
CREATE INDEX idx_ticket_created_status ON ticket(created_at, status);

-- Índices para hardware
CREATE INDEX idx_hardware_category_status ON hardware(category, status);
CREATE INDEX idx_hardware_serial_status ON hardware(serial_number, status);

-- Índices para clientes
CREATE INDEX idx_client_company ON client(company);
CREATE INDEX idx_client_created ON client(created_at);

-- Índices para usuarios
CREATE INDEX idx_user_role ON user(role);
CREATE INDEX idx_user_created ON user(created_at);

-- =====================================================
-- CONFIGURACIÓN DE PERMISOS
-- =====================================================

-- Crear usuario para la aplicación (ejecutar como root)
-- CREATE USER 'techsupport_user'@'localhost' IDENTIFIED BY 'tu_contraseña_segura';
-- GRANT ALL PRIVILEGES ON techsupport_db.* TO 'techsupport_user'@'localhost';
-- FLUSH PRIVILEGES;

-- =====================================================
-- MENSAJE DE CONFIRMACIÓN
-- =====================================================

SELECT 'Base de datos techsupport_db creada exitosamente!' as mensaje;
SELECT COUNT(*) as total_usuarios FROM user;
SELECT COUNT(*) as total_clientes FROM client;
SELECT COUNT(*) as total_hardware FROM hardware;
SELECT COUNT(*) as total_tickets FROM ticket;
SELECT COUNT(*) as total_comentarios FROM ticket_comment;
SELECT COUNT(*) as total_historial FROM ticket_history; 