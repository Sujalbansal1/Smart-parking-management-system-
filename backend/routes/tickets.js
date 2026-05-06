const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const sql = `
    SELECT 
      T.Ticket_ID,
      T.Vehicle_No,
      V.Model,
      V.Type,
      T.Slot_ID,
      P.Location AS Slot_Location,
      V.Arrival_Time,
      V.Exit_Time
    FROM TICKET T
    JOIN VEHICLE V ON T.Vehicle_No = V.Vehicle_No
    JOIN PARKING_SLOT P ON T.Slot_ID = P.Slot_ID
    ORDER BY T.Ticket_ID DESC
  `;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

module.exports = router;
