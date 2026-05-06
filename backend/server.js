const express = require('express');
const cors = require('cors');

const userRoutes = require('./routes/users');
const vehicleRoutes = require('./routes/vehicles');
const ticketRoutes = require('./routes/tickets');
const transactionRoutes = require('./routes/transactions');
const staffRoutes = require('./routes/staff');

const path = require('path');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

app.use('/users', userRoutes);
app.use('/vehicles', vehicleRoutes);
app.use('/tickets', ticketRoutes);
app.use('/transactions', transactionRoutes);
app.use('/staff', staffRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Smart Parking Management System API is running.' });
});

const db = require('./db');

app.get('/slots', (req, res) => {
  const sql = 'SELECT * FROM PARKING_SLOT';
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.put('/slots/:id', (req, res) => {
  const sql = 'UPDATE PARKING_SLOT SET Is_Occupied = NOT Is_Occupied WHERE Slot_ID = ?';
  db.query(sql, [req.params.id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Slot status updated' });
  });
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
