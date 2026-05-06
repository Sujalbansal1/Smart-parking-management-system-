const API_URL = 'http://localhost:5000';

let users = [];
let vehicles = [];
let slots = [];
let tickets = [];
let transactions = [];
let staff = [];

// ===== Navigation =====
const navLinks = document.querySelectorAll('.nav-link');
const pages = document.querySelectorAll('.page');
const pageTitle = document.getElementById('pageTitle');
const titles = {
  dashboard: 'Dashboard', users: 'User Management', vehicles: 'Vehicle Management',
  slots: 'Parking Slots', tickets: 'Tickets', transactions: 'Transactions & Payments', staff: 'Staff'
};

navLinks.forEach(link => {
  link.addEventListener('click', async e => {
    e.preventDefault();
    const page = link.dataset.page;
    navLinks.forEach(l => l.classList.remove('active'));
    link.classList.add('active');
    pages.forEach(p => p.classList.remove('active'));
    document.getElementById('page-' + page).classList.add('active');
    pageTitle.textContent = titles[page];
    document.getElementById('sidebar').classList.remove('open');
    
    // Fetch data based on page
    if(page === 'dashboard') await renderDashboard();
    else if(page === 'users') await renderUsers();
    else if(page === 'vehicles') await renderVehicles();
    else if(page === 'slots') await renderSlots();
    else if(page === 'tickets') await renderTickets();
    else if(page === 'transactions') await renderTransactions();
    else if(page === 'staff') await renderStaff();
  });
});

document.getElementById('menuToggle').addEventListener('click', () => {
  document.getElementById('sidebar').classList.toggle('open');
});

// ===== Renderers =====
async function renderDashboard() {
  const resSlots = await fetch(`${API_URL}/slots`);
  slots = await resSlots.json();
  const resVehicles = await fetch(`${API_URL}/vehicles`);
  vehicles = await resVehicles.json();
  const resTrans = await fetch(`${API_URL}/transactions`);
  transactions = await resTrans.json();

  const total = slots.length;
  const occupied = slots.filter(s => s.Is_Occupied).length;
  const available = total - occupied;
  const revenue = transactions.filter(t => t.Status === 'Success' || t.Status === 'Paid').reduce((s, t) => s + Number(t.Amount), 0);
  const activeVehicles = vehicles.filter(v => !v.Exit_Time).length;

  document.getElementById('stat-total').textContent = total;
  document.getElementById('stat-available').textContent = available;
  document.getElementById('stat-occupied').textContent = occupied;
  document.getElementById('stat-vehicles').textContent = activeVehicles;
  document.getElementById('stat-revenue').textContent = '₹' + revenue.toFixed(2);

  const pct = total ? Math.round((occupied / total) * 100) : 0;
  document.getElementById('occupancyBar').style.width = pct + '%';
  document.getElementById('occupancyText').textContent = pct + '% occupied (' + occupied + ' / ' + total + ')';

  const recent = document.getElementById('recentVehicles');
  recent.innerHTML = vehicles.slice(0, 5).map(v =>
    `<li><span><strong>${v.Vehicle_No}</strong> · ${v.Model}</span><span class="muted">${new Date(v.Arrival_Time).toLocaleString()}</span></li>`
  ).join('');
}

async function renderUsers() {
  const res = await fetch(`${API_URL}/users`);
  users = await res.json();
  document.getElementById('usersTable').innerHTML = users.map((u, i) => `
    <tr>
      <td>${i + 1}</td><td>${u.Name}</td><td>${u.Contact_Info}</td>
      <td>
        <button class="btn btn-ghost btn-sm" onclick="editUser('${u.User_ID}')">Edit</button>
        <button class="btn btn-danger btn-sm" onclick="deleteUser('${u.User_ID}')">Delete</button>
      </td>
    </tr>
  `).join('');
}

async function renderVehicles() {
  const res = await fetch(`${API_URL}/vehicles`);
  vehicles = await res.json();
  document.getElementById('vehiclesTable').innerHTML = vehicles.map(v => `
    <tr>
      <td><strong>${v.Vehicle_No}</strong></td><td>${v.Model}</td><td>${v.Type}</td>
      <td>${new Date(v.Arrival_Time).toLocaleString()}</td><td>${v.Exit_Time ? new Date(v.Exit_Time).toLocaleString() : '-'}</td>
      <td>
        ${!v.Exit_Time ? `<button class="btn btn-success btn-sm" onclick="exitVehicle('${v.Vehicle_No}')">Exit</button>` : ''}
        <button class="btn btn-danger btn-sm" onclick="deleteVehicle('${v.Vehicle_No}')">Delete</button>
      </td>
    </tr>
  `).join('');
}

async function renderSlots() {
  const res = await fetch(`${API_URL}/slots`);
  slots = await res.json();
  document.getElementById('slotsGrid').innerHTML = slots.map(s => {
    const statusClass = s.Is_Occupied ? 'occupied' : 'free';
    const statusText = s.Is_Occupied ? 'occupied' : 'free';
    return `
    <div class="slot ${statusClass}" onclick="toggleSlot('${s.Slot_ID}')">
      <div class="slot-id">S${String(s.Slot_ID).padStart(3, '0')}</div>
      <div class="slot-loc">${s.Location}</div>
      <span class="slot-status">${statusText}</span>
    </div>
  `}).join('');
}

async function renderTickets() {
  const res = await fetch(`${API_URL}/tickets`);
  tickets = await res.json();
  document.getElementById('ticketsGrid').innerHTML = tickets.map(t => `
    <div class="ticket">
      <div class="ticket-id">TICKET</div>
      <h4>T${t.Ticket_ID}</h4>
      <div class="ticket-row"><span>Vehicle</span><span><strong>${t.Vehicle_No}</strong></span></div>
      <div class="ticket-row"><span>Slot</span><span><strong>S${String(t.Slot_ID).padStart(3, '0')}</strong></span></div>
      <div class="ticket-row"><span>Issued</span><span>${new Date(t.Arrival_Time).toLocaleDateString()}</span></div>
    </div>
  `).join('');
}

async function renderTransactions() {
  const res = await fetch(`${API_URL}/transactions`);
  transactions = await res.json();
  document.getElementById('transactionsTable').innerHTML = transactions.map(t => {
    const cls = t.Status === 'Success' ? 'badge-success' : t.Status === 'Pending' ? 'badge-warn' : 'badge-danger';
    return `
      <tr>
        <td>TXN-${t.Trans_ID}</td><td>₹${Number(t.Amount).toFixed(2)}</td><td>PAY-${t.Payment_ID || 'N/A'}</td>
        <td>${t.Method || '-'}</td><td><span class="badge ${cls}">${t.Status || 'Pending'}</span></td>
      </tr>`;
  }).join('');
}

async function renderStaff() {
  const res = await fetch(`${API_URL}/staff`);
  staff = await res.json();
  document.getElementById('staffTable').innerHTML = staff.map((s, i) => `
    <tr>
      <td>${i + 1}</td><td>${s.Name}</td><td>${s.Role}</td>
      <td>
        <button class="btn btn-ghost btn-sm" onclick="editStaff('${s.Staff_ID}')">Edit</button>
        <button class="btn btn-danger btn-sm" onclick="deleteStaff('${s.Staff_ID}')">Delete</button>
      </td>
    </tr>
  `).join('');
}

// ===== Modal helpers =====
function openModal(id) { document.getElementById(id).classList.add('active'); }
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

document.querySelectorAll('.modal').forEach(m => {
  m.addEventListener('click', e => { if (e.target === m) m.classList.remove('active'); });
});

// ===== Users CRUD =====
function openUserModal() {
  document.getElementById('userModalTitle').textContent = 'Add User';
  document.getElementById('userId').value = '';
  document.getElementById('userName').value = '';
  document.getElementById('userContact').value = '';
  openModal('userModal');
}
function editUser(id) {
  const u = users.find(x => String(x.User_ID) === String(id));
  document.getElementById('userModalTitle').textContent = 'Edit User';
  document.getElementById('userId').value = u.User_ID;
  document.getElementById('userName').value = u.Name;
  document.getElementById('userContact').value = u.Contact_Info;
  openModal('userModal');
}
async function deleteUser(id) {
  if (confirm('Delete this user?')) { 
    const res = await fetch(`${API_URL}/users/${id}`, { method: 'DELETE' });
    if (!res.ok) {
      const err = await res.json();
      alert('Error deleting user: ' + err.error);
    }
    renderUsers(); 
  }
}
async function saveUser(e) {
  e.preventDefault();
  const id = document.getElementById('userId').value;
  const name = document.getElementById('userName').value;
  const contact = document.getElementById('userContact').value;
  
  if (id) {
    await fetch(`${API_URL}/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ Name: name, Contact_Info: contact })
    });
  } else {
    await fetch(`${API_URL}/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ Name: name, Contact_Info: contact })
    });
  }
  closeModal('userModal'); 
  renderUsers();
}

// ===== Vehicles =====
async function openVehicleModal() {
  document.getElementById('vehicleId').value = '';
  document.getElementById('vehicleNumber').value = '';
  document.getElementById('vehicleModel').value = '';
  document.getElementById('vehicleType').value = 'Car';
  
  // Need to pick a user.
  const res = await fetch(`${API_URL}/users`);
  const fetchedUsers = await res.json();
  if (fetchedUsers.length === 0) {
    alert('Please add a user first before adding a vehicle.');
    return;
  }
  document.getElementById('vehicleUserIdGroup') ? null : addUserIdSelect(fetchedUsers);
  openModal('vehicleModal');
}

function addUserIdSelect(fetchedUsers) {
  const form = document.getElementById('vehicleForm');
  const div = document.createElement('div');
  div.className = 'form-group';
  div.id = 'vehicleUserIdGroup';
  div.innerHTML = `
    <label>Owner (User)</label>
    <select id="vehicleUserSelect" required class="input">
      ${fetchedUsers.map(u => `<option value="${u.User_ID}">${u.Name}</option>`).join('')}
    </select>
  `;
  form.insertBefore(div, form.querySelector('.form-actions'));
}

async function deleteVehicle(id) {
  if (confirm('Delete this vehicle entry?')) { 
    const res = await fetch(`${API_URL}/vehicles/${id}`, { method: 'DELETE' });
    if (!res.ok) {
      const err = await res.json();
      alert('Error deleting vehicle: ' + err.error);
    }
    renderVehicles(); 
  }
}

async function exitVehicle(id) {
  if (confirm('Process exit for this vehicle?')) {
    const method = prompt("Enter payment method (e.g. Credit Card, Cash):", "Credit Card");
    if(method) {
      await fetch(`${API_URL}/vehicles/exit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ Vehicle_No: id, Payment_Method: method })
      });
      renderVehicles();
    }
  }
}

async function saveVehicle(e) {
  e.preventDefault();
  const number = document.getElementById('vehicleNumber').value;
  const model = document.getElementById('vehicleModel').value;
  const type = document.getElementById('vehicleType').value;
  const userId = document.getElementById('vehicleUserSelect')?.value || 1; 

  const res = await fetch(`${API_URL}/vehicles/entry`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ Vehicle_No: number, Model: model, Type: type, User_ID: userId })
  });
  
  if (!res.ok) {
    const err = await res.json();
    alert('Error: ' + err.error);
  }

  closeModal('vehicleModal'); 
  renderVehicles(); 
}

// ===== Slots =====
async function toggleSlot(id) {
  await fetch(`${API_URL}/slots/${id}`, { method: 'PUT' });
  renderSlots();
}

// ===== Staff CRUD =====
function openStaffModal() {
  document.getElementById('staffModalTitle').textContent = 'Add Staff';
  document.getElementById('staffId').value = '';
  document.getElementById('staffName').value = '';
  document.getElementById('staffRole').value = 'Manager';
  openModal('staffModal');
}
function editStaff(id) {
  const s = staff.find(x => String(x.Staff_ID) === String(id));
  document.getElementById('staffModalTitle').textContent = 'Edit Staff';
  document.getElementById('staffId').value = s.Staff_ID;
  document.getElementById('staffName').value = s.Name;
  document.getElementById('staffRole').value = s.Role;
  openModal('staffModal');
}
async function deleteStaff(id) {
  if (confirm('Delete this staff member?')) { 
    const res = await fetch(`${API_URL}/staff/${id}`, { method: 'DELETE' });
    if (!res.ok) {
      const err = await res.json();
      alert('Error deleting staff: ' + err.error);
    }
    renderStaff(); 
  }
}
async function saveStaff(e) {
  e.preventDefault();
  const id = document.getElementById('staffId').value;
  const name = document.getElementById('staffName').value;
  const role = document.getElementById('staffRole').value;
  
  if (id) {
    await fetch(`${API_URL}/staff/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ Name: name, Role: role })
    });
  } else {
    await fetch(`${API_URL}/staff`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ Name: name, Role: role })
    });
  }
  closeModal('staffModal'); 
  renderStaff();
}

// ===== Init =====
async function init() {
  await renderDashboard();
  renderUsers();
  renderVehicles();
  renderSlots();
  renderTickets();
  renderTransactions();
  renderStaff();
}

init();
