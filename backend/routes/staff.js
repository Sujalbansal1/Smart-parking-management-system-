const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const sql = 'SELECT * FROM STAFF';
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.post('/', (req, res) => {
  const { Name, Role } = req.body;
  if (!Name || !Role) {
    return res.status(400).json({ error: 'Name and Role are required.' });
  }
  const sql = 'INSERT INTO STAFF (Name, Role) VALUES (?, ?)';
  db.query(sql, [Name, Role], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Staff member added.', Staff_ID: result.insertId });
  });
});
router.put('/:id', (req, res) => {
  const { Name, Role } = req.body;
  const sql = 'UPDATE STAFF SET Name = ?, Role = ? WHERE Staff_ID = ?';
  db.query(sql, [Name, Role, req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Staff updated' });
  });
});

router.delete('/:id', (req, res) => {
  const sql = 'DELETE FROM STAFF WHERE Staff_ID = ?';
  db.query(sql, [req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Staff deleted' });
  });
});

module.exports = router;
