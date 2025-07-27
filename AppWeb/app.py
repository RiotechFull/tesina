from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import pymysql
import os
from contextlib import contextmanager

app = Flask(__name__)
app.config['SECRET_KEY'] = '8fba8773f60d4aa600ad5104e219688a767347b99e9aff35dabfbd4f8cbd0179'

# Configuración de la base de datos MySQL
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  # Cambiar por tu usuario de MySQL
    'password': 'test123456',  # Cambiar por tu contraseña de MySQL
    'database': 'techsupport_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Función para obtener conexión a la base de datos
@contextmanager
def get_db_connection():
    connection = pymysql.connect(**DB_CONFIG)
    try:
        yield connection
    finally:
        connection.close()

# Función para ejecutar consultas
def execute_query(query, params=None, fetch_one=False, fetch_all=False):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(query, params or ())
            if fetch_one:
                return cursor.fetchone()
            elif fetch_all:
                return cursor.fetchall()
            else:
                connection.commit()
                return cursor.lastrowid

# Clase User para Flask-Login
class User(UserMixin):
    def __init__(self, user_data):
        self.id = user_data['id']
        self.first_name = user_data['first_name']
        self.last_name = user_data['last_name']
        self.email = user_data['email']
        self.phone = user_data['phone']
        self.role = user_data['role']
        self.password_hash = user_data['password_hash']
        self.created_at = user_data['created_at']
    
    @property
    def name(self):
        return f"{self.first_name} {self.last_name}"
    
    @staticmethod
    def get_by_id(user_id):
        query = "SELECT * FROM user WHERE id = %s"
        user_data = execute_query(query, (user_id,), fetch_one=True)
        return User(user_data) if user_data else None
    
    @staticmethod
    def get_by_email(email):
        query = "SELECT * FROM user WHERE email = %s"
        user_data = execute_query(query, (email,), fetch_one=True)
        return User(user_data) if user_data else None

@login_manager.user_loader
def load_user(user_id):
    return User.get_by_id(int(user_id))

# Funciones auxiliares para obtener datos
def get_stats():
    query = """
    SELECT 
        COUNT(*) as total_tickets,
        SUM(CASE WHEN status != 'cerrado' THEN 1 ELSE 0 END) as pending_tickets,
        SUM(CASE WHEN status = 'cerrado' THEN 1 ELSE 0 END) as completed_tickets,
        COUNT(DISTINCT client_id) as total_clients
    FROM ticket
    """
    return execute_query(query, fetch_one=True)

def get_recent_tickets(limit=5):
    query = """
    SELECT 
        t.id,
        t.title,
        t.status,
        t.priority,
        t.created_at,
        c.name as client_name
    FROM ticket t
    LEFT JOIN client c ON t.client_id = c.id
    ORDER BY t.created_at DESC
    LIMIT %s
    """
    return execute_query(query, (limit,), fetch_all=True)

def get_recent_activity():
    # Actividad simulada - en un sistema real vendría de una tabla de logs
    return [
        {'icon': 'ticket-alt', 'description': 'Nuevo ticket creado #123', 'timestamp': '2 minutos atrás'},
        {'icon': 'check-circle', 'description': 'Ticket #120 completado', 'timestamp': '1 hora atrás'},
        {'icon': 'user-plus', 'description': 'Nuevo cliente registrado', 'timestamp': '3 horas atrás'}
    ]

def get_all_tickets():
    query = """
    SELECT 
        t.id,
        t.title,
        t.status,
        t.priority,
        t.created_at,
        c.name as client_name,
        CONCAT(u.first_name, ' ', u.last_name) as technician_name
    FROM ticket t
    LEFT JOIN client c ON t.client_id = c.id
    LEFT JOIN user u ON t.technician_id = u.id
    ORDER BY t.created_at DESC
    """
    return execute_query(query, fetch_all=True)

def get_all_clients():
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
    return execute_query(query, fetch_all=True)

def get_all_inventory():
    query = """
    SELECT 
        h.*,
        CASE 
            WHEN h.category = 'computadora' THEN 'desktop'
            WHEN h.category = 'impresora' THEN 'print'
            WHEN h.category = 'red' THEN 'network-wired'
            WHEN h.category = 'periferico' THEN 'keyboard'
            WHEN h.category = 'servidor' THEN 'server'
            ELSE 'box'
        END as icon
    FROM hardware h
    ORDER BY h.name
    """
    return execute_query(query, fetch_all=True)

def get_technicians():
    query = """
    SELECT id, CONCAT(first_name, ' ', last_name) as name
    FROM user 
    WHERE role IN ('technician', 'admin')
    ORDER BY first_name
    """
    return execute_query(query, fetch_all=True)

# Rutas principales
@app.route('/')
@login_required
def index():
    stats = get_stats()
    recent_tickets = get_recent_tickets()
    recent_activity = get_recent_activity()
    
    return render_template('index.html', 
                         stats=stats, 
                         recent_tickets=recent_tickets,
                         recent_activity=recent_activity)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        remember = request.form.get('remember') == 'on'
        
        user = User.get_by_email(email)
        
        if user and check_password_hash(user.password_hash, password):
            login_user(user, remember=remember)
            flash('Inicio de sesión exitoso', 'success')
            return redirect(url_for('index'))
        else:
            flash('Credenciales inválidas', 'error')
    
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        first_name = request.form.get('first_name')
        last_name = request.form.get('last_name')
        email = request.form.get('email')
        phone = request.form.get('phone')
        role = request.form.get('role')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')
        
        # Validaciones básicas
        if password != confirm_password:
            flash('Las contraseñas no coinciden', 'error')
            return render_template('registro.html')
        
        # Verificar si el email ya existe
        existing_user = User.get_by_email(email)
        if existing_user:
            flash('El correo electrónico ya está registrado', 'error')
            return render_template('registro.html')
        
        # Crear nuevo usuario
        query = """
        INSERT INTO user (first_name, last_name, email, phone, role, password_hash)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        password_hash = generate_password_hash(password)
        execute_query(query, (first_name, last_name, email, phone, role, password_hash))
        
        flash('Cuenta creada exitosamente. Por favor inicia sesión.', 'success')
        return redirect(url_for('login'))
    
    return render_template('registro.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Sesión cerrada exitosamente', 'success')
    return redirect(url_for('login'))

# API Routes para AJAX
@app.route('/api/tickets', methods=['GET', 'POST'])
@login_required
def api_tickets():
    if request.method == 'GET':
        tickets = get_all_tickets()
        return jsonify(tickets)
    
    elif request.method == 'POST':
        data = request.get_json()
        
        query = """
        INSERT INTO ticket (title, description, client_id, priority, hardware_id)
        VALUES (%s, %s, %s, %s, %s)
        """
        ticket_id = execute_query(query, (
            data['title'],
            data['description'],
            data['client_id'],
            data['priority'],
            data.get('hardware_id')
        ))
        
        return jsonify({'message': 'Ticket creado exitosamente', 'id': ticket_id})

@app.route('/api/tickets/<int:ticket_id>', methods=['GET', 'PUT', 'DELETE'])
@login_required
def api_ticket(ticket_id):
    if request.method == 'GET':
        query = "SELECT * FROM ticket WHERE id = %s"
        ticket = execute_query(query, (ticket_id,), fetch_one=True)
        if not ticket:
            return jsonify({'error': 'Ticket no encontrado'}), 404
        return jsonify(ticket)
    
    elif request.method == 'PUT':
        data = request.get_json()
        query = """
        UPDATE ticket 
        SET title = %s, description = %s, status = %s, priority = %s, 
            technician_id = %s, hardware_id = %s
        WHERE id = %s
        """
        execute_query(query, (
            data['title'],
            data['description'],
            data['status'],
            data['priority'],
            data.get('technician_id'),
            data.get('hardware_id'),
            ticket_id
        ))
        return jsonify({'message': 'Ticket actualizado exitosamente'})
    
    elif request.method == 'DELETE':
        query = "DELETE FROM ticket WHERE id = %s"
        execute_query(query, (ticket_id,))
        return jsonify({'message': 'Ticket eliminado exitosamente'})

@app.route('/api/clients', methods=['GET', 'POST'])
@login_required
def api_clients():
    if request.method == 'GET':
        clients = get_all_clients()
        return jsonify(clients)
    
    elif request.method == 'POST':
        data = request.get_json()
        
        query = """
        INSERT INTO client (name, email, phone, company, address)
        VALUES (%s, %s, %s, %s, %s)
        """
        client_id = execute_query(query, (
            data['name'],
            data['email'],
            data['phone'],
            data.get('company'),
            data.get('address')
        ))
        
        return jsonify({'message': 'Cliente creado exitosamente', 'id': client_id})

@app.route('/api/clients/<int:client_id>', methods=['GET', 'PUT'])
@login_required
def api_client(client_id):
    if request.method == 'GET':
        query = "SELECT * FROM client WHERE id = %s"
        client = execute_query(query, (client_id,), fetch_one=True)
        if not client:
            return jsonify({'error': 'Cliente no encontrado'}), 404
        return jsonify(client)
    
    elif request.method == 'PUT':
        data = request.get_json()
        query = """
        UPDATE client 
        SET name = %s, email = %s, phone = %s, company = %s, address = %s
        WHERE id = %s
        """
        execute_query(query, (
            data['name'],
            data['email'],
            data['phone'],
            data.get('company'),
            data.get('address'),
            client_id
        ))
        return jsonify({'message': 'Cliente actualizado exitosamente'})

@app.route('/api/inventory', methods=['GET', 'POST'])
@login_required
def api_inventory():
    if request.method == 'GET':
        inventory = get_all_inventory()
        return jsonify(inventory)
    
    elif request.method == 'POST':
        data = request.get_json()
        
        query = """
        INSERT INTO hardware (name, category, serial_number, status, description)
        VALUES (%s, %s, %s, %s, %s)
        """
        item_id = execute_query(query, (
            data['name'],
            data['category'],
            data['serial_number'],
            data['status'],
            data.get('description')
        ))
        
        return jsonify({'message': 'Item creado exitosamente', 'id': item_id})

@app.route('/api/inventory/<int:item_id>', methods=['GET', 'PUT'])
@login_required
def api_inventory_item(item_id):
    if request.method == 'GET':
        query = "SELECT * FROM hardware WHERE id = %s"
        item = execute_query(query, (item_id,), fetch_one=True)
        if not item:
            return jsonify({'error': 'Item no encontrado'}), 404
        return jsonify(item)
    
    elif request.method == 'PUT':
        data = request.get_json()
        query = """
        UPDATE hardware 
        SET name = %s, category = %s, serial_number = %s, status = %s, description = %s
        WHERE id = %s
        """
        execute_query(query, (
            data['name'],
            data['category'],
            data['serial_number'],
            data['status'],
            data.get('description'),
            item_id
        ))
        return jsonify({'message': 'Item actualizado exitosamente'})

# Rutas para obtener datos para los templates
@app.route('/dashboard')
@login_required
def dashboard():
    return redirect(url_for('index'))

@app.route('/tickets')
@login_required
def tickets():
    tickets = get_all_tickets()
    clients = get_all_clients()
    technicians = get_technicians()
    inventory = get_all_inventory()
    
    return render_template('index.html', 
                         tickets=tickets,
                         clients=clients,
                         technicians=technicians,
                         inventory=inventory)

@app.route('/clients')
@login_required
def clients():
    clients = get_all_clients()
    return render_template('index.html', clients=clients)

@app.route('/inventory')
@login_required
def inventory():
    inventory = get_all_inventory()
    return render_template('index.html', inventory=inventory)

@app.route('/reports')
@login_required
def reports():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True) 