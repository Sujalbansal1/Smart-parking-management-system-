const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const sql = 'SELECT * FROM USER';
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.post('/', (req, res) => {
  const { Name, Contact_Info } = req.body;
  if (!Name || !Contact_Info) {
    return res.status(400).json({ error: 'Name and Contact_Info are required.' });
  }
  const sql = 'INSERT INTO USER (Name, Contact_Info) VALUES (?, ?)';
  db.query(sql, [Name, Contact_Info], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'User created.', User_ID: result.insertId });
  });
});
router.put('/:id', (req, res) => {
  const { Name, Contact_Info } = req.body;
  const sql = 'UPDATE USER SET Name = ?, Contact_Info = ? WHERE User_ID = ?';
  db.query(sql, [Name, Contact_Info, req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'User updated' });
  });
});

router.delete('/:id', (req, res) => {
  const sql = 'DELETE FROM USER WHERE User_ID = ?';
  db.query(sql, [req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'User deleted' });
  });
});

module.exports = router;
