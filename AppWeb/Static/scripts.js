// Global Variables
let currentSection = 'dashboard';
let charts = {};

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

// Initialize Application
function initializeApp() {
    setupNavigation();
    setupModals();
    setupForms();
    setupFilters();
    setupCharts();
    setupEventListeners();
}

// Navigation Setup
function setupNavigation() {
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetSection = this.getAttribute('href').substring(1);
            showSection(targetSection);
        });
    });
}

function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active class from all nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    // Show target section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
        currentSection = sectionId;
    }
    
    // Add active class to corresponding nav link
    const activeLink = document.querySelector(`[href="#${sectionId}"]`);
    if (activeLink) {
        activeLink.classList.add('active');
    }
    
    // Update charts if reports section
    if (sectionId === 'reports') {
        updateCharts();
    }
}

// Modal Management
function setupModals() {
    // Close modal when clicking outside
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal')) {
            closeModal(e.target.id);
        }
    });
    
    // Close modal with Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeAllModals();
        }
    });
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
        
        // Reset form if exists
        const form = modal.querySelector('form');
        if (form) {
            form.reset();
        }
    }
}

function closeAllModals() {
    document.querySelectorAll('.modal').forEach(modal => {
        modal.classList.remove('active');
    });
    document.body.style.overflow = '';
}

// Form Management
function setupForms() {
    // New Ticket Form
    const newTicketForm = document.getElementById('newTicketForm');
    if (newTicketForm) {
        newTicketForm.addEventListener('submit', handleNewTicket);
    }
    
    // New Client Form
    const newClientForm = document.getElementById('newClientForm');
    if (newClientForm) {
        newClientForm.addEventListener('submit', handleNewClient);
    }
    
    // New Item Form
    const newItemForm = document.getElementById('newItemForm');
    if (newItemForm) {
        newItemForm.addEventListener('submit', handleNewItem);
    }
}

async function handleNewTicket(e) {
    e.preventDefault();
    showLoading();
    
    const formData = new FormData(e.target);
    const ticketData = {
        title: formData.get('title'),
        client_id: formData.get('client_id'),
        priority: formData.get('priority'),
        description: formData.get('description'),
        hardware_id: formData.get('hardware_id') || null
    };
    
    try {
        const response = await fetch('/api/tickets', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(ticketData)
        });
        
        if (response.ok) {
            const result = await response.json();
            showToast('Ticket creado exitosamente', 'success');
            closeModal('newTicketModal');
            refreshTickets();
        } else {
            throw new Error('Error al crear ticket');
        }
    } catch (error) {
        showToast('Error al crear ticket: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

async function handleNewClient(e) {
    e.preventDefault();
    showLoading();
    
    const formData = new FormData(e.target);
    const clientData = {
        name: formData.get('name'),
        email: formData.get('email'),
        phone: formData.get('phone'),
        company: formData.get('company'),
        address: formData.get('address')
    };
    
    try {
        const response = await fetch('/api/clients', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(clientData)
        });
        
        if (response.ok) {
            const result = await response.json();
            showToast('Cliente creado exitosamente', 'success');
            closeModal('newClientModal');
            refreshClients();
        } else {
            throw new Error('Error al crear cliente');
        }
    } catch (error) {
        showToast('Error al crear cliente: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

async function handleNewItem(e) {
    e.preventDefault();
    showLoading();
    
    const formData = new FormData(e.target);
    const itemData = {
        name: formData.get('name'),
        category: formData.get('category'),
        serial_number: formData.get('serial_number'),
        status: formData.get('status'),
        description: formData.get('description')
    };
    
    try {
        const response = await fetch('/api/inventory', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(itemData)
        });
        
        if (response.ok) {
            const result = await response.json();
            showToast('Item creado exitosamente', 'success');
            closeModal('newItemModal');
            refreshInventory();
        } else {
            throw new Error('Error al crear item');
        }
    } catch (error) {
        showToast('Error al crear item: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Filter Management
function setupFilters() {
    const statusFilter = document.getElementById('status-filter');
    const priorityFilter = document.getElementById('priority-filter');
    const technicianFilter = document.getElementById('technician-filter');
    const searchInput = document.getElementById('search-tickets');
    
    if (statusFilter) {
        statusFilter.addEventListener('change', filterTickets);
    }
    if (priorityFilter) {
        priorityFilter.addEventListener('change', filterTickets);
    }
    if (technicianFilter) {
        technicianFilter.addEventListener('change', filterTickets);
    }
    if (searchInput) {
        searchInput.addEventListener('input', debounce(filterTickets, 300));
    }
}

function filterTickets() {
    const status = document.getElementById('status-filter')?.value;
    const priority = document.getElementById('priority-filter')?.value;
    const technician = document.getElementById('technician-filter')?.value;
    const search = document.getElementById('search-tickets')?.value.toLowerCase();
    
    const rows = document.querySelectorAll('#tickets-table-body tr');
    
    rows.forEach(row => {
        let show = true;
        
        // Status filter
        if (status && row.querySelector('.status-badge').textContent.trim() !== status) {
            show = false;
        }
        
        // Priority filter
        if (priority && row.querySelector('.priority-badge').textContent.trim() !== priority) {
            show = false;
        }
        
        // Technician filter
        if (technician) {
            const technicianCell = row.cells[5]; // Technician column
            if (technicianCell && !technicianCell.textContent.includes(technician)) {
                show = false;
            }
        }
        
        // Search filter
        if (search) {
            const text = row.textContent.toLowerCase();
            if (!text.includes(search)) {
                show = false;
            }
        }
        
        row.style.display = show ? '' : 'none';
    });
}

// Chart Management
function setupCharts() {
    if (typeof Chart === 'undefined') {
        console.warn('Chart.js not loaded');
        return;
    }
    
    // Tickets by Status Chart
    const ticketsByStatusCtx = document.getElementById('ticketsByStatusChart');
    if (ticketsByStatusCtx) {
        charts.ticketsByStatus = new Chart(ticketsByStatusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Abierto', 'En Proceso', 'Esperando Cliente', 'Cerrado'],
                datasets: [{
                    data: [12, 8, 5, 25],
                    backgroundColor: [
                        '#3b82f6',
                        '#f59e0b',
                        '#ef4444',
                        '#10b981'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    }
    
    // Tickets by Month Chart
    const ticketsByMonthCtx = document.getElementById('ticketsByMonthChart');
    if (ticketsByMonthCtx) {
        charts.ticketsByMonth = new Chart(ticketsByMonthCtx, {
            type: 'line',
            data: {
                labels: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'],
                datasets: [{
                    label: 'Tickets',
                    data: [65, 59, 80, 81, 56, 55],
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    
    // Technician Performance Chart
    const technicianPerformanceCtx = document.getElementById('technicianPerformanceChart');
    if (technicianPerformanceCtx) {
        charts.technicianPerformance = new Chart(technicianPerformanceCtx, {
            type: 'bar',
            data: {
                labels: ['Juan Pérez', 'María García', 'Carlos López', 'Ana Martínez'],
                datasets: [{
                    label: 'Tickets Completados',
                    data: [45, 38, 52, 41],
                    backgroundColor: '#667eea'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    
    // Hardware Types Chart
    const hardwareTypesCtx = document.getElementById('hardwareTypesChart');
    if (hardwareTypesCtx) {
        charts.hardwareTypes = new Chart(hardwareTypesCtx, {
            type: 'pie',
            data: {
                labels: ['Computadoras', 'Impresoras', 'Equipos de Red', 'Periféricos', 'Servidores'],
                datasets: [{
                    data: [35, 25, 20, 15, 5],
                    backgroundColor: [
                        '#667eea',
                        '#f59e0b',
                        '#10b981',
                        '#ef4444',
                        '#8b5cf6'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    }
}

function updateCharts() {
    // This function would fetch real data and update charts
    // For now, we'll just ensure charts are properly sized
    Object.values(charts).forEach(chart => {
        if (chart) {
            chart.resize();
        }
    });
}

// Ticket Management Functions
function viewTicket(ticketId) {
    showLoading();
    
    fetch(`/api/tickets/${ticketId}`)
        .then(response => response.json())
        .then(ticket => {
            // Create and show ticket detail modal
            showTicketDetailModal(ticket);
        })
        .catch(error => {
            showToast('Error al cargar ticket: ' + error.message, 'error');
        })
        .finally(() => {
            hideLoading();
        });
}

function editTicket(ticketId) {
    showLoading();
    
    fetch(`/api/tickets/${ticketId}`)
        .then(response => response.json())
        .then(ticket => {
            // Populate edit form and show modal
            populateTicketEditForm(ticket);
            openModal('editTicketModal');
        })
        .catch(error => {
            showToast('Error al cargar ticket: ' + error.message, 'error');
        })
        .finally(() => {
            hideLoading();
        });
}

async function deleteTicket(ticketId) {
    if (!confirm('¿Está seguro de que desea eliminar este ticket?')) {
        return;
    }
    
    showLoading();
    
    try {
        const response = await fetch(`/api/tickets/${ticketId}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            showToast('Ticket eliminado exitosamente', 'success');
            refreshTickets();
        } else {
            throw new Error('Error al eliminar ticket');
        }
    } catch (error) {
        showToast('Error al eliminar ticket: ' + error.message, 'error');
    } finally {
        hideLoading();
    }
}

// Client Management Functions
function viewClient(clientId) {
    showLoading();
    
    fetch(`/api/clients/${clientId}`)
        .then(response => response.json())
        .then(client => {
            showClientDetailModal(client);
        })
        .catch(error => {
            showToast('Error al cargar cliente: ' + error.message, 'error');
        })
        .finally(() => {
            hideLoading();
        });
}

function editClient(clientId) {
    showLoading();
    
    fetch(`/api/clients/${clientId}`)
        .then(response => response.json())
        .then(client => {
            populateClientEditForm(client);
            openModal('editClientModal');
        })
        .catch(error => {
            showToast('Error al cargar cliente: ' + error.message, 'error');
        })
        .finally(() => {
            hideLoading();
        });
}

// Inventory Management Functions
function viewItem(itemId) {
    showLoading();
    
    fetch(`/api/inventory/${itemId}`)
        .then(response => response.json())
        .then(item => {
            showItemDetailModal(item);
        })
        .catch(error => {
            showToast('Error al cargar item: ' + error.message, 'error');
        })
        .finally(() => {
            hideLoading();
        });
}

function editItem(itemId) {
    showLoading();
    
    fetch(`/api/inventory/${itemId}`)
        .then(response => response.json())
        .then(item => {
            populateItemEditForm(item);
            openModal('editItemModal');
        })
        .catch(error => {
            showToast('Error al cargar item: ' + error.message, 'error');
        })
        .finally(() => {
            hideLoading();
        });
}

// Refresh Functions
function refreshTickets() {
    // Reload tickets data
    location.reload();
}

function refreshClients() {
    // Reload clients data
    location.reload();
}

function refreshInventory() {
    // Reload inventory data
    location.reload();
}

// Utility Functions
function showLoading() {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
        loadingOverlay.classList.add('active');
    }
}

function hideLoading() {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
        loadingOverlay.classList.remove('active');
    }
}

function showToast(message, type = 'info') {
    const toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) return;
    
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    const icon = document.createElement('i');
    icon.className = getToastIcon(type);
    
    const messageEl = document.createElement('span');
    messageEl.textContent = message;
    
    const closeBtn = document.createElement('button');
    closeBtn.innerHTML = '&times;';
    closeBtn.className = 'toast-close';
    closeBtn.onclick = () => removeToast(toast);
    
    toast.appendChild(icon);
    toast.appendChild(messageEl);
    toast.appendChild(closeBtn);
    
    toastContainer.appendChild(toast);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        removeToast(toast);
    }, 5000);
}

function removeToast(toast) {
    if (toast && toast.parentNode) {
        toast.parentNode.removeChild(toast);
    }
}

function getToastIcon(type) {
    switch (type) {
        case 'success': return 'fas fa-check-circle';
        case 'error': return 'fas fa-exclamation-circle';
        case 'warning': return 'fas fa-exclamation-triangle';
        default: return 'fas fa-info-circle';
    }
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Event Listeners Setup
function setupEventListeners() {
    // Global click handler for dynamic elements
    document.addEventListener('click', function(e) {
        // Handle dynamic button clicks
        if (e.target.matches('[data-action]')) {
            const action = e.target.getAttribute('data-action');
            const id = e.target.getAttribute('data-id');
            
            switch (action) {
                case 'view-ticket':
                    viewTicket(id);
                    break;
                case 'edit-ticket':
                    editTicket(id);
                    break;
                case 'delete-ticket':
                    deleteTicket(id);
                    break;
                case 'view-client':
                    viewClient(id);
                    break;
                case 'edit-client':
                    editClient(id);
                    break;
                case 'view-item':
                    viewItem(id);
                    break;
                case 'edit-item':
                    editItem(id);
                    break;
            }
        }
    });
    
    // Handle form validation
    document.addEventListener('input', function(e) {
        if (e.target.matches('input[required], select[required], textarea[required]')) {
            validateField(e.target);
        }
    });
}

// Form Validation
function validateField(field) {
    const value = field.value.trim();
    const isValid = value.length > 0;
    
    if (isValid) {
        field.classList.remove('error');
        field.classList.add('valid');
    } else {
        field.classList.remove('valid');
        field.classList.add('error');
    }
    
    return isValid;
}

function validateForm(form) {
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;
    
    requiredFields.forEach(field => {
        if (!validateField(field)) {
            isValid = false;
        }
    });
    
    return isValid;
}

// Export functions for global access
window.openModal = openModal;
window.closeModal = closeModal;
window.viewTicket = viewTicket;
window.editTicket = editTicket;
window.deleteTicket = deleteTicket;
window.viewClient = viewClient;
window.editClient = editClient;
window.viewItem = viewItem;
window.editItem = editItem;
