#!/usr/bin/env python3
"""
Script para actualizar las contraseñas de los usuarios existentes
en la base de datos con hashes compatibles con Werkzeug.
"""

import pymysql
from werkzeug.security import generate_password_hash

# Configuración de la base de datos
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  # Cambiar por tu usuario de MySQL
    'password': 'test123456',  # Cambiar por tu contraseña de MySQL
    'database': 'techsupport_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

def update_user_passwords():
    """Actualiza las contraseñas de todos los usuarios con hashes compatibles."""
    
    # Contraseñas por defecto para cada usuario
    default_passwords = {
        'juan.perez@techsupport.com': 'admin123',
        'maria.garcia@techsupport.com': 'tech123',
        'carlos.lopez@techsupport.com': 'tech123',
        'ana.martinez@techsupport.com': 'manager123',
        'luis.rodriguez@techsupport.com': 'support123'
    }
    
    try:
        # Conectar a la base de datos
        connection = pymysql.connect(**DB_CONFIG)
        
        with connection.cursor() as cursor:
            # Obtener todos los usuarios
            cursor.execute("SELECT id, email FROM user")
            users = cursor.fetchall()
            
            print(f"Encontrados {len(users)} usuarios para actualizar...")
            
            # Actualizar cada usuario
            for user in users:
                email = user['email']
                user_id = user['id']
                
                if email in default_passwords:
                    password = default_passwords[email]
                    password_hash = generate_password_hash(password)
                    
                    # Actualizar el hash de la contraseña
                    cursor.execute(
                        "UPDATE user SET password_hash = %s WHERE id = %s",
                        (password_hash, user_id)
                    )
                    
                    print(f"✅ Usuario {email} actualizado con contraseña: {password}")
                else:
                    # Para usuarios no listados, usar una contraseña por defecto
                    password = 'password123'
                    password_hash = generate_password_hash(password)
                    
                    cursor.execute(
                        "UPDATE user SET password_hash = %s WHERE id = %s",
                        (password_hash, user_id)
                    )
                    
                    print(f"✅ Usuario {email} actualizado con contraseña por defecto: {password}")
            
            # Confirmar cambios
            connection.commit()
            print("\n🎉 Todas las contraseñas han sido actualizadas exitosamente!")
            print("\n📋 Credenciales de acceso:")
            print("=" * 50)
            for email, password in default_passwords.items():
                print(f"Email: {email}")
                print(f"Contraseña: {password}")
                print("-" * 30)
            
    except Exception as e:
        print(f"❌ Error al actualizar las contraseñas: {e}")
    finally:
        if 'connection' in locals():
            connection.close()

if __name__ == "__main__":
    print("🔄 Actualizando contraseñas de usuarios...")
    update_user_passwords() 