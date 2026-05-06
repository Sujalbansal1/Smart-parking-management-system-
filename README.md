# 🚗 Smart Parking Management System

A full-stack **Smart Parking Management System** built using **Node.js, Express.js, MySQL, HTML, CSS, and JavaScript**.
This project demonstrates a complete DBMS-based web application for managing parking slots, vehicles, tickets, and payments.

---

## 📌 Features

* 🔐 User Management
* 🚘 Vehicle Entry & Exit System
* 🅿️ Automatic Parking Slot Allocation
* 🎫 Ticket Generation
* 💳 Transaction & Payment Handling
* 📊 Dashboard with real-time data
* 🔄 Dynamic frontend with API integration

---

## 🛠️ Technologies Used

* **Frontend:** HTML, CSS, JavaScript
* **Backend:** Node.js, Express.js
* **Database:** MySQL
* **API Communication:** Fetch API

---

## 📁 Project Structure

```
smart-parking/
├── frontend/        # HTML, CSS, JS files
├── backend/         # Node.js server and routes
│   ├── routes/
│   ├── db.js
│   └── server.js
├── database/
│   └── schema.sql
```

---

## ⚙️ Setup Instructions

### 1️⃣ Install Requirements

* Install Node.js
* Install MySQL

---

### 2️⃣ Setup Database

Start MySQL:

```
net start MySQL80
```

Run schema file:

```
mysql -u root -p < C:\schema.sql
```

---

### 3️⃣ Run Backend

```
cd backend
npm install
npm start
```

---

### 4️⃣ Open Application

Open browser and go to:

```
http://localhost:5000
```

---

## 🧠 How It Works

1. User enters vehicle details
2. System assigns a free parking slot
3. Ticket is generated
4. On exit:

   * Time is calculated
   * Payment is generated
   * Slot is freed

---

## 🧪 Sample Data

* Predefined staff members
* Predefined parking slots
* Data stored in MySQL database

---

## 🚀 Future Improvements

* Authentication system
* Online payment integration
* QR-based entry/exit
* Mobile app support

---

## 📚 Learning Outcomes

* Database design using ER models
* Backend API development
* Frontend-backend integration
* Real-world system simulation

---

## 👨‍💻 Authors

**Sujal Bansal**
**Chitvan Goel**

---

## ⭐ Acknowledgement

This project was developed as part of a **DBMS course** to demonstrate real-world application of database concepts.
