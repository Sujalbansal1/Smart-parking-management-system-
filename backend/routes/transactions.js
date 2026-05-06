const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const sql = `
    SELECT 
      TR.Trans_ID,
      TR.Ticket_ID,
      TK.Vehicle_No,
      TR.Amount,
      P.Payment_ID,
      P.Method,
      P.Status
    FROM TRANSACTIONS TR
    JOIN TICKET TK ON TR.Ticket_ID = TK.Ticket_ID
    LEFT JOIN PAYMENT P ON P.Trans_ID = TR.Trans_ID
    ORDER BY TR.Trans_ID DESC
  `;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

module.exports = router;
