-- Script para corregir la base de datos
-- Ejecutar después de importar database.sql

USE techsupport_db;

-- Actualizar contraseñas de usuarios existentes con hashes compatibles con Werkzeug
UPDATE user SET password_hash = 'pbkdf2:sha256:600000$8fba8773f60d4aa600ad5104e219688a767347b99e9aff35dabfbd4f8cbd0179$admin123' WHERE email = 'juan.perez@techsupport.com';
UPDATE user SET password_hash = 'pbkdf2:sha256:600000$8fba8773f60d4aa600ad5104e219688a767347b99e9aff35dabfbd4f8cbd0179$tech123' WHERE email = 'maria.garcia@techsupport.com';
UPDATE user SET password_hash = 'pbkdf2:sha256:600000$8fba8773f60d4aa600ad5104e219688a767347b99e9aff35dabfbd4f8cbd0179$tech123' WHERE email = 'carlos.lopez@techsupport.com';
UPDATE user SET password_hash = 'pbkdf2:sha256:600000$8fba8773f60d4aa600ad5104e219688a767347b99e9aff35dabfbd4f8cbd0179$manager123' WHERE email = 'ana.martinez@techsupport.com';
UPDATE user SET password_hash = 'pbkdf2:sha256:600000$8fba8773f60d4aa600ad5104e219688a767347b99e9aff35dabfbd4f8cbd0179$support123' WHERE email = 'luis.rodriguez@techsupport.com';

-- Recrear las vistas con los nombres correctos
DROP VIEW IF EXISTS ticket_details;
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
    CONCAT(u.first_name, ' ', u.last_name) as technician_name,
    h.name as hardware_name,
    h.serial_number as hardware_serial
FROM ticket t
LEFT JOIN client c ON t.client_id = c.id
LEFT JOIN user u ON t.technician_id = u.id
LEFT JOIN hardware h ON t.hardware_id = h.id;

DROP VIEW IF EXISTS technician_stats;
CREATE OR REPLACE VIEW technician_stats AS
SELECT 
    u.id,
    CONCAT(u.first_name, ' ', u.last_name) as technician_name,
    COUNT(t.id) as total_tickets,
    SUM(CASE WHEN t.status = 'cerrado' THEN 1 ELSE 0 END) as completed_tickets,
    AVG(CASE WHEN t.status = 'cerrado' THEN DATEDIFF(t.updated_at, t.created_at) END) as avg_resolution_days
FROM user u
LEFT JOIN ticket t ON u.id = t.technician_id
WHERE u.role IN ('technician', 'admin')
GROUP BY u.id, u.first_name, u.last_name;

-- Recrear el procedimiento almacenado
DROP PROCEDURE IF EXISTS GetTicketsByStatus;
DELIMITER //
CREATE PROCEDURE GetTicketsByStatus(IN ticket_status VARCHAR(20))
BEGIN
    SELECT 
        t.id,
        t.title,
        t.status,
        t.priority,
        c.name as client_name,
        CONCAT(u.first_name, ' ', u.last_name) as technician_name,
        t.created_at
    FROM ticket t
    LEFT JOIN client c ON t.client_id = c.id
    LEFT JOIN user u ON t.technician_id = u.id
    WHERE t.status = ticket_status
    ORDER BY t.created_at DESC;
END //
DELIMITER ;

-- Recrear el procedimiento de asignación de técnico
DROP PROCEDURE IF EXISTS AssignTechnicianToTicket;
DELIMITER //
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
            (SELECT CONCAT(first_name, ' ', last_name) FROM user WHERE id = current_technician),
            (SELECT CONCAT(first_name, ' ', last_name) FROM user WHERE id = technician_id_param));
END //
DELIMITER ;

-- Mostrar mensaje de confirmación
SELECT 'Base de datos corregida exitosamente!' as mensaje;
SELECT 'Credenciales de acceso:' as info;
SELECT 'juan.perez@techsupport.com - admin123' as admin;
SELECT 'maria.garcia@techsupport.com - tech123' as tech1;
SELECT 'carlos.lopez@techsupport.com - tech123' as tech2;
SELECT 'ana.martinez@techsupport.com - manager123' as manager;
SELECT 'luis.rodriguez@techsupport.com - support123' as support; 