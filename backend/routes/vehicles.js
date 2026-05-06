const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const sql = 'SELECT * FROM VEHICLE ORDER BY Arrival_Time DESC';
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.delete('/:id', (req, res) => {
  const sql = 'DELETE FROM VEHICLE WHERE Vehicle_No = ?';
  db.query(sql, [req.params.id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Vehicle deleted' });
  });
});

router.post('/entry', (req, res) => {
  const { Vehicle_No, Model, Type, User_ID } = req.body;

  if (!Vehicle_No || !Model || !Type || !User_ID) {
    return res.status(400).json({ error: 'Vehicle_No, Model, Type, and User_ID are required.' });
  }

  const insertVehicle = 'INSERT INTO VEHICLE (Vehicle_No, Model, Type, User_ID) VALUES (?, ?, ?, ?)';
  db.query(insertVehicle, [Vehicle_No, Model, Type, User_ID], (err) => {
    if (err) return res.status(500).json({ error: err.message });

    const findSlot = 'SELECT Slot_ID FROM PARKING_SLOT WHERE Is_Occupied = FALSE LIMIT 1';
    db.query(findSlot, (err, slots) => {
      if (err) return res.status(500).json({ error: err.message });
      if (slots.length === 0) return res.status(409).json({ error: 'No free parking slots available.' });

      const slotId = slots[0].Slot_ID;

      const markSlot = 'UPDATE PARKING_SLOT SET Is_Occupied = TRUE WHERE Slot_ID = ?';
      db.query(markSlot, [slotId], (err) => {
        if (err) return res.status(500).json({ error: err.message });

        const createTicket = 'INSERT INTO TICKET (Vehicle_No, Slot_ID) VALUES (?, ?)';
        db.query(createTicket, [Vehicle_No, slotId], (err, ticketResult) => {
          if (err) return res.status(500).json({ error: err.message });

          res.status(201).json({
            message: 'Vehicle entry recorded.',
            Ticket_ID: ticketResult.insertId,
            Slot_ID: slotId,
            Vehicle_No
          });
        });
      });
    });
  });
});

router.post('/exit', (req, res) => {
  const { Vehicle_No, Payment_Method } = req.body;

  if (!Vehicle_No || !Payment_Method) {
    return res.status(400).json({ error: 'Vehicle_No and Payment_Method are required.' });
  }

  const getVehicle = 'SELECT * FROM VEHICLE WHERE Vehicle_No = ? AND Exit_Time IS NULL';
  db.query(getVehicle, [Vehicle_No], (err, vehicles) => {
    if (err) return res.status(500).json({ error: err.message });
    if (vehicles.length === 0) return res.status(404).json({ error: 'Active vehicle session not found.' });

    const vehicle = vehicles[0];
    const arrivalTime = new Date(vehicle.Arrival_Time);
    const exitTime = new Date();
    const hoursParked = Math.max(1, Math.ceil((exitTime - arrivalTime) / (1000 * 60 * 60)));
    const ratePerHour = 50;
    const amount = hoursParked * ratePerHour;

    const updateExit = 'UPDATE VEHICLE SET Exit_Time = ? WHERE Vehicle_No = ?';
    db.query(updateExit, [exitTime, Vehicle_No], (err) => {
      if (err) return res.status(500).json({ error: err.message });

      const getTicket = 'SELECT * FROM TICKET WHERE Vehicle_No = ?';
      db.query(getTicket, [Vehicle_No], (err, tickets) => {
        if (err) return res.status(500).json({ error: err.message });
        if (tickets.length === 0) return res.status(404).json({ error: 'Ticket not found.' });

        const ticket = tickets[tickets.length - 1];

        const freeSlot = 'UPDATE PARKING_SLOT SET Is_Occupied = FALSE WHERE Slot_ID = ?';
        db.query(freeSlot, [ticket.Slot_ID], (err) => {
          if (err) return res.status(500).json({ error: err.message });

          const createTransaction = 'INSERT INTO TRANSACTIONS (Ticket_ID, Amount) VALUES (?, ?)';
          db.query(createTransaction, [ticket.Ticket_ID, amount], (err, transResult) => {
            if (err) return res.status(500).json({ error: err.message });

            const transId = transResult.insertId;

            const createPayment = 'INSERT INTO PAYMENT (Trans_ID, Method, Status) VALUES (?, ?, ?)';
            db.query(createPayment, [transId, Payment_Method, 'Success'], (err, payResult) => {
              if (err) return res.status(500).json({ error: err.message });

              res.json({
                message: 'Vehicle exit processed.',
                Vehicle_No,
                Hours_Parked: hoursParked,
                Amount_Charged: amount,
                Trans_ID: transId,
                Payment_ID: payResult.insertId,
                Payment_Status: 'Success'
              });
            });
          });
        });
      });
    });
  });
});

module.exports = router;
