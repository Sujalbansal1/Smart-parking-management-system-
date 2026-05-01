# 🚗 Smart Parking Management System (DBMS Project)

## 📌 Project Overview

The **Smart Parking Management System** is a database-driven solution designed to automate parking operations efficiently. It replaces traditional manual systems with a structured DBMS approach to manage vehicles, parking slots, tickets, and billing.

This project is implemented using **SQL and PL/SQL**, focusing on backend database design and automation.

---

## 🎯 Objectives

* Design an **Entity-Relationship (ER) Model**
* Convert ER model into **Relational Schema**
* Apply **Normalization up to 3NF**
* Implement **SQL queries (DDL & DML)**
* Use **PL/SQL procedures, functions, and triggers**
* Maintain **data integrity and consistency**

---

## 🧠 Key Features

* 🚘 Vehicle registration and tracking
* 🅿️ Automatic parking slot allocation
* 🎫 Ticket generation system
* 💰 Billing and payment management
* 🔄 Real-time slot updates using triggers
* 🔐 Secure and consistent data handling

---

## 🗂️ Database Design

### Entities:

* USER
* VEHICLE
* TICKET
* PARKING_SLOT
* STAFF
* TRANSACTION
* PAYMENT

### Relationships:

* A User owns Vehicles (1)
* Vehicle generates Ticket
* Ticket allocated to Parking Slot
* Transaction generated per Ticket
* Payment linked to Transaction

(*Based on ER diagram from project report*)

---

## ⚙️ Technologies Used

* MySQL / Oracle DBMS
* SQL (DDL, DML)
* PL/SQL (Procedures, Functions, Triggers)
* SQL Developer / MySQL Workbench

---

## 🧮 Normalization

The database is normalized up to **Third Normal Form (3NF)**:

* 1NF: Atomic values
* 2NF: No partial dependency
* 3NF: No transitive dependency

---

## 🔄 Functional Modules

* Vehicle Entry & Exit Management
* Slot Allocation System
* Billing & Payment Processing
* Staff Management
* Transaction Handling

---

## 🛠️ How to Run the Project

1. Open MySQL Workbench / SQL Developer
2. Import the `.sql` file
3. Execute all queries
4. Run SELECT queries to test output

---

## 📊 Expected Outcome

* Efficient parking management
* Reduced human errors
* Automated billing system
* Improved data consistency

---

## 👨‍💻 Contributors

* Sujal Bansal
* Chitvan Goel

---

## 📄 Project Report

See full documentation here: 

---

## 📌 Conclusion

This project demonstrates the practical implementation of DBMS concepts like normalization, ER modeling, transactions, and PL/SQL automation to solve real-world parking problems.

---
