#!/usr/bin/env python3
"""
Script para probar la conexión a la base de datos y verificar que los datos se cargan correctamente.
"""

import pymysql
from contextlib import contextmanager

# Configuración de la base de datos
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  # Cambiar por tu usuario de MySQL
    'password': 'test123456',  # Cambiar por tu contraseña de MySQL
    'database': 'techsupport_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

@contextmanager
def get_db_connection():
    connection = pymysql.connect(**DB_CONFIG)
    try:
        yield connection
    finally:
        connection.close()

def test_database_connection():
    """Prueba la conexión a la base de datos."""
    try:
        with get_db_connection() as connection:
            print("✅ Conexión a la base de datos exitosa")
            return True
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_clients_data():
    """Prueba que los datos de clientes se cargan correctamente."""
    try:
        with get_db_connection() as connection:
            with connection.cursor() as cursor:
                # Verificar si hay clientes
                cursor.execute("SELECT COUNT(*) as count FROM client")
                result = cursor.fetchone()
                client_count = result['count']
                print(f"📊 Total de clientes en la base de datos: {client_count}")
                
                if client_count > 0:
                    # Mostrar algunos clientes
                    cursor.execute("SELECT * FROM client LIMIT 3")
                    clients = cursor.fetchall()
                    print("\n📋 Primeros 3 clientes:")
                    for client in clients:
                        print(f"  - ID: {client['id']}, Nombre: {client['name']}, Email: {client['email']}")
                else:
                    print("⚠️  No hay clientes en la base de datos")
                
                return client_count > 0
    except Exception as e:
        print(f"❌ Error al cargar clientes: {e}")
        return False

def test_tickets_data():
    """Prueba que los datos de tickets se cargan correctamente."""
    try:
        with get_db_connection() as connection:
            with connection.cursor() as cursor:
                # Verificar si hay tickets
                cursor.execute("SELECT COUNT(*) as count FROM ticket")
                result = cursor.fetchone()
                ticket_count = result['count']
                print(f"📊 Total de tickets en la base de datos: {ticket_count}")
                
                if ticket_count > 0:
                    # Mostrar algunos tickets
                    cursor.execute("SELECT * FROM ticket LIMIT 3")
                    tickets = cursor.fetchall()
                    print("\n📋 Primeros 3 tickets:")
                    for ticket in tickets:
                        print(f"  - ID: {ticket['id']}, Título: {ticket['title']}, Estado: {ticket['status']}")
                else:
                    print("⚠️  No hay tickets en la base de datos")
                
                return ticket_count > 0
    except Exception as e:
        print(f"❌ Error al cargar tickets: {e}")
        return False

def test_users_data():
    """Prueba que los datos de usuarios se cargan correctamente."""
    try:
        with get_db_connection() as connection:
            with connection.cursor() as cursor:
                # Verificar si hay usuarios
                cursor.execute("SELECT COUNT(*) as count FROM user")
                result = cursor.fetchone()
                user_count = result['count']
                print(f"📊 Total de usuarios en la base de datos: {user_count}")
                
                if user_count > 0:
                    # Mostrar algunos usuarios
                    cursor.execute("SELECT id, first_name, last_name, email, role FROM user LIMIT 3")
                    users = cursor.fetchall()
                    print("\n📋 Primeros 3 usuarios:")
                    for user in users:
                        print(f"  - ID: {user['id']}, Nombre: {user['first_name']} {user['last_name']}, Email: {user['email']}, Rol: {user['role']}")
                else:
                    print("⚠️  No hay usuarios en la base de datos")
                
                return user_count > 0
    except Exception as e:
        print(f"❌ Error al cargar usuarios: {e}")
        return False

def test_query_functions():
    """Prueba las funciones de consulta que usa la aplicación."""
    try:
        with get_db_connection() as connection:
            with connection.cursor() as cursor:
                # Probar la consulta de clientes con estadísticas
                query = """
                SELECT 
                    c.*,
                    COUNT(t.id) as total_tickets,
                    SUM(CASE WHEN t.status != 'cerrado' THEN 1 ELSE 0 END) as active_tickets
                FROM client c
                LEFT JOIN ticket t ON c.id = t.client_id
                GROUP BY c.id
                ORDER BY c.name
                """
                cursor.execute(query)
                clients = cursor.fetchall()
                print(f"\n📊 Clientes con estadísticas cargados: {len(clients)}")
                
                if clients:
                    print("📋 Primer cliente con estadísticas:")
                    client = clients[0]
                    print(f"  - Nombre: {client['name']}")
                    print(f"  - Total tickets: {client['total_tickets']}")
                    print(f"  - Tickets activos: {client['active_tickets']}")
                
                return len(clients) > 0
    except Exception as e:
        print(f"❌ Error al probar funciones de consulta: {e}")
        return False

if __name__ == "__main__":
    print("🔍 Probando la base de datos...")
    print("=" * 50)
    
    # Probar conexión
    if not test_database_connection():
        print("\n❌ No se puede continuar sin conexión a la base de datos")
        exit(1)
    
    print("\n" + "=" * 50)
    
    # Probar datos
    test_users_data()
    test_clients_data()
    test_tickets_data()
    test_query_functions()
    
    print("\n" + "=" * 50)
    print("✅ Pruebas completadas") 