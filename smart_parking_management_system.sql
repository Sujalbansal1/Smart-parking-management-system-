-- ============================================================
--  SMART PARKING MANAGEMENT SYSTEM
--  Course: UCS310 – Database Management Systems
--  Thapar Institute of Engineering and Technology
--  Group: Sujal Bansal  (1024030659)
--         Chitvan Goel  (1024030910)
-- ============================================================


-- ============================================================
-- SECTION 1: DDL – CREATE TABLES (Normalized up to 3NF)
-- ============================================================

-- Drop tables in reverse FK dependency order (safe re-run)
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS TRANSACTION_LOG;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS PARKING_SLOT;
DROP TABLE IF EXISTS VEHICLE;
DROP TABLE IF EXISTS STAFF;
DROP TABLE IF EXISTS USER_ACCOUNT;


-- 1. USER_ACCOUNT
CREATE TABLE USER_ACCOUNT (
    User_ID      INT           PRIMARY KEY AUTO_INCREMENT,
    Name         VARCHAR(100)  NOT NULL,
    Contact_Info VARCHAR(15)   NOT NULL UNIQUE
);

-- 2. STAFF
CREATE TABLE STAFF (
    Staff_ID  INT          PRIMARY KEY AUTO_INCREMENT,
    Name      VARCHAR(100) NOT NULL,
    Role      VARCHAR(50)  NOT NULL
);

-- 3. VEHICLE
CREATE TABLE VEHICLE (
    Vehicle_No   VARCHAR(20)  PRIMARY KEY,
    Model        VARCHAR(50)  NOT NULL,
    Type         VARCHAR(20)  NOT NULL,           -- e.g. Car, Bike, Truck
    Arrival_Time DATETIME,
    Exit_Time    DATETIME,
    User_ID      INT          NOT NULL,
    CONSTRAINT fk_vehicle_user  FOREIGN KEY (User_ID) REFERENCES USER_ACCOUNT(User_ID)
);

-- 4. PARKING_SLOT
CREATE TABLE PARKING_SLOT (
    Slot_ID     INT          PRIMARY KEY AUTO_INCREMENT,
    Location    VARCHAR(50)  NOT NULL,
    Is_Occupied BOOLEAN      NOT NULL DEFAULT FALSE,
    Staff_ID    INT,
    CONSTRAINT fk_slot_staff FOREIGN KEY (Staff_ID) REFERENCES STAFF(Staff_ID)
);

-- 5. TICKET
CREATE TABLE TICKET (
    Ticket_ID  INT         PRIMARY KEY AUTO_INCREMENT,
    Vehicle_No VARCHAR(20) NOT NULL,
    Slot_ID    INT         NOT NULL,
    CONSTRAINT fk_ticket_vehicle FOREIGN KEY (Vehicle_No) REFERENCES VEHICLE(Vehicle_No),
    CONSTRAINT fk_ticket_slot    FOREIGN KEY (Slot_ID)    REFERENCES PARKING_SLOT(Slot_ID)
);

-- 6. TRANSACTION_LOG  (named TRANSACTION_LOG to avoid MySQL reserved word conflict)
CREATE TABLE TRANSACTION_LOG (
    Trans_ID  INT   PRIMARY KEY AUTO_INCREMENT,
    Ticket_ID INT   NOT NULL,
    Amount    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_trans_ticket FOREIGN KEY (Ticket_ID) REFERENCES TICKET(Ticket_ID)
);

-- 7. PAYMENT
CREATE TABLE PAYMENT (
    Payment_ID INT          PRIMARY KEY AUTO_INCREMENT,
    Trans_ID   INT          NOT NULL,
    Method     VARCHAR(30)  NOT NULL,             -- e.g. Cash, Card, UPI
    Status     VARCHAR(20)  NOT NULL DEFAULT 'Pending', -- Pending / Paid / Failed
    CONSTRAINT fk_payment_trans FOREIGN KEY (Trans_ID) REFERENCES TRANSACTION_LOG(Trans_ID)
);


-- ============================================================
-- SECTION 2: DML – SAMPLE DATA INSERTION
-- ============================================================

-- Users
INSERT INTO USER_ACCOUNT (Name, Contact_Info) VALUES
    ('Brahmdeep Singh', '9876543210'),
    ('Keerat Brar',     '9876543211'),
    ('Simar Arora',     '9876543212'),
    ('Ravi Kumar',      '9876543213'),
    ('Priya Sharma',    '9876543214');

-- Staff
INSERT INTO STAFF (Name, Role) VALUES
    ('Harpreet Singh', 'Supervisor'),
    ('Mandeep Kaur',   'Attendant'),
    ('Suresh Babu',    'Attendant');

-- Parking Slots
INSERT INTO PARKING_SLOT (Location, Is_Occupied, Staff_ID) VALUES
    ('Block A - Slot 1', FALSE, 1),
    ('Block A - Slot 2', FALSE, 1),
    ('Block B - Slot 1', FALSE, 2),
    ('Block B - Slot 2', FALSE, 2),
    ('Block C - Slot 1', FALSE, 3);

-- Vehicles (entry time set, exit NULL = still parked)
INSERT INTO VEHICLE (Vehicle_No, Model, Type, Arrival_Time, Exit_Time, User_ID) VALUES
    ('PB10AB1234', 'Swift Dzire', 'Car',  '2026-05-01 09:00:00', NULL, 1),
    ('PB10CD5678', 'Honda Activa','Bike', '2026-05-01 09:30:00', NULL, 2),
    ('PB10EF9012', 'Innova Crysta','Car', '2026-05-01 10:00:00', NULL, 3),
    ('PB10GH3456', 'Pulsar 150',  'Bike', '2026-05-01 08:00:00', '2026-05-01 11:00:00', 4),
    ('PB10IJ7890', 'Maruti Alto', 'Car',  '2026-05-01 07:30:00', '2026-05-01 10:30:00', 5);

-- Tickets
INSERT INTO TICKET (Vehicle_No, Slot_ID) VALUES
    ('PB10AB1234', 1),
    ('PB10CD5678', 3),
    ('PB10EF9012', 2),
    ('PB10GH3456', 4),
    ('PB10IJ7890', 5);

-- Update slots that are currently occupied
UPDATE PARKING_SLOT SET Is_Occupied = TRUE  WHERE Slot_ID IN (1, 2, 3);

-- Transactions (fees pre-calculated; PL/SQL function will auto-compute for new entries)
INSERT INTO TRANSACTION_LOG (Ticket_ID, Amount) VALUES
    (4, 30.00),   -- PB10GH3456: 3 hrs × ₹10
    (5, 60.00);   -- PB10IJ7890: 3 hrs × ₹20 (car rate)

-- Payments
INSERT INTO PAYMENT (Trans_ID, Method, Status) VALUES
    (1, 'Cash', 'Paid'),
    (2, 'UPI',  'Paid');


-- ============================================================
-- SECTION 3: SQL QUERIES
-- ============================================================

-- Q1: List all currently occupied parking slots with vehicle details
SELECT ps.Slot_ID, ps.Location, v.Vehicle_No, v.Model, v.Type,
       v.Arrival_Time, ua.Name AS Owner
FROM   PARKING_SLOT ps
JOIN   TICKET       t  ON ps.Slot_ID    = t.Slot_ID
JOIN   VEHICLE      v  ON t.Vehicle_No  = v.Vehicle_No
JOIN   USER_ACCOUNT ua ON v.User_ID     = ua.User_ID
WHERE  ps.Is_Occupied = TRUE;

-- Q2: Count of available vs occupied slots per block (Location prefix)
SELECT SUBSTRING(Location, 1, 7)   AS Block,
       SUM(Is_Occupied = FALSE)     AS Available,
       SUM(Is_Occupied = TRUE)      AS Occupied
FROM   PARKING_SLOT
GROUP  BY Block;

-- Q3: Total revenue collected today
SELECT COALESCE(SUM(tl.Amount), 0) AS Total_Revenue
FROM   TRANSACTION_LOG tl
JOIN   PAYMENT         p  ON tl.Trans_ID = p.Trans_ID
WHERE  p.Status = 'Paid'
AND    DATE(NOW()) = CURDATE();

-- Q4: Vehicles that have exited with their parking duration and fee paid
SELECT v.Vehicle_No, v.Model, ua.Name AS Owner,
       v.Arrival_Time, v.Exit_Time,
       TIMESTAMPDIFF(HOUR, v.Arrival_Time, v.Exit_Time) AS Hours_Parked,
       tl.Amount AS Fee_Paid, p.Method AS Payment_Method
FROM   VEHICLE          v
JOIN   USER_ACCOUNT     ua ON v.User_ID    = ua.User_ID
JOIN   TICKET           tk ON v.Vehicle_No = tk.Vehicle_No
JOIN   TRANSACTION_LOG  tl ON tk.Ticket_ID = tl.Trans_ID
JOIN   PAYMENT          p  ON tl.Trans_ID  = p.Trans_ID
WHERE  v.Exit_Time IS NOT NULL;

-- Q5: Staff workload – number of slots managed per staff member
SELECT s.Staff_ID, s.Name, s.Role, COUNT(ps.Slot_ID) AS Slots_Managed
FROM   STAFF        s
JOIN   PARKING_SLOT ps ON s.Staff_ID = ps.Staff_ID
GROUP  BY s.Staff_ID, s.Name, s.Role
ORDER  BY Slots_Managed DESC;

-- Q6: Vehicles still parked for more than 2 hours (potential overstay alert)
SELECT v.Vehicle_No, v.Model, v.Type, ua.Name AS Owner,
       ua.Contact_Info,
       TIMESTAMPDIFF(HOUR, v.Arrival_Time, NOW()) AS Hours_In
FROM   VEHICLE      v
JOIN   USER_ACCOUNT ua ON v.User_ID = ua.User_ID
WHERE  v.Exit_Time IS NULL
AND    TIMESTAMPDIFF(HOUR, v.Arrival_Time, NOW()) > 2;

-- Q7: View – Parking Summary (stored as a virtual table)
CREATE OR REPLACE VIEW vw_Parking_Summary AS
SELECT ps.Slot_ID, ps.Location,
       CASE WHEN ps.Is_Occupied THEN v.Vehicle_No  ELSE 'FREE' END AS Vehicle,
       CASE WHEN ps.Is_Occupied THEN v.Type         ELSE '--'   END AS Type,
       CASE WHEN ps.Is_Occupied THEN v.Arrival_Time ELSE NULL   END AS Entry_Time,
       s.Name AS Managed_By
FROM   PARKING_SLOT ps
LEFT JOIN TICKET       tk ON ps.Slot_ID    = tk.Slot_ID  AND ps.Is_Occupied = TRUE
LEFT JOIN VEHICLE       v ON tk.Vehicle_No = v.Vehicle_No AND v.Exit_Time IS NULL
LEFT JOIN STAFF         s ON ps.Staff_ID   = s.Staff_ID;

SELECT * FROM vw_Parking_Summary;


-- ============================================================
-- SECTION 4: PL/SQL – STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- -----------------------------------------------------------------
-- SP 1: Allocate a free parking slot to an arriving vehicle
--        Creates a VEHICLE record, TICKET, and marks slot occupied.
-- -----------------------------------------------------------------
CREATE PROCEDURE sp_AllocateSlot(
    IN  p_Vehicle_No  VARCHAR(20),
    IN  p_Model       VARCHAR(50),
    IN  p_Type        VARCHAR(20),
    IN  p_User_ID     INT,
    OUT p_Slot_ID     INT,
    OUT p_Ticket_ID   INT,
    OUT p_Message     VARCHAR(200)
)
BEGIN
    DECLARE v_Slot_ID INT DEFAULT NULL;

    -- Find any free slot
    SELECT Slot_ID INTO v_Slot_ID
    FROM   PARKING_SLOT
    WHERE  Is_Occupied = FALSE
    LIMIT  1;

    IF v_Slot_ID IS NULL THEN
        SET p_Slot_ID   = NULL;
        SET p_Ticket_ID = NULL;
        SET p_Message   = 'ERROR: No free parking slots available.';
    ELSE
        -- Insert vehicle record
        INSERT INTO VEHICLE (Vehicle_No, Model, Type, Arrival_Time, User_ID)
        VALUES (p_Vehicle_No, p_Model, p_Type, NOW(), p_User_ID);

        -- Issue ticket
        INSERT INTO TICKET (Vehicle_No, Slot_ID) VALUES (p_Vehicle_No, v_Slot_ID);
        SET p_Ticket_ID = LAST_INSERT_ID();

        -- Mark slot as occupied
        UPDATE PARKING_SLOT SET Is_Occupied = TRUE WHERE Slot_ID = v_Slot_ID;

        SET p_Slot_ID = v_Slot_ID;
        SET p_Message = CONCAT('SUCCESS: Slot ', v_Slot_ID, ' allocated. Ticket ID: ', p_Ticket_ID);
    END IF;
END$$


-- -----------------------------------------------------------------
-- SP 2: Process vehicle exit – record exit time, compute fee,
--        create transaction & payment record, free the slot.
-- -----------------------------------------------------------------
CREATE PROCEDURE sp_ProcessExit(
    IN  p_Vehicle_No  VARCHAR(20),
    IN  p_Method      VARCHAR(30),
    OUT p_Amount      DECIMAL(10,2),
    OUT p_Message     VARCHAR(200)
)
BEGIN
    DECLARE v_Arrival    DATETIME;
    DECLARE v_Ticket_ID  INT;
    DECLARE v_Slot_ID    INT;
    DECLARE v_Hours      INT;
    DECLARE v_Rate       DECIMAL(10,2);
    DECLARE v_Type       VARCHAR(20);
    DECLARE v_Trans_ID   INT;

    -- Fetch vehicle details
    SELECT Arrival_Time, Type INTO v_Arrival, v_Type
    FROM   VEHICLE WHERE Vehicle_No = p_Vehicle_No AND Exit_Time IS NULL;

    IF v_Arrival IS NULL THEN
        SET p_Amount  = 0;
        SET p_Message = 'ERROR: Vehicle not found or already exited.';
    ELSE
        -- Compute hours (minimum 1 hour charge)
        SET v_Hours = GREATEST(1, TIMESTAMPDIFF(HOUR, v_Arrival, NOW()));

        -- Rate card: Car = ₹20/hr, Bike = ₹10/hr, Truck = ₹30/hr
        SET v_Rate = CASE v_Type
                        WHEN 'Car'   THEN 20.00
                        WHEN 'Bike'  THEN 10.00
                        WHEN 'Truck' THEN 30.00
                        ELSE 15.00
                     END;

        SET p_Amount = v_Hours * v_Rate;

        -- Update exit time
        UPDATE VEHICLE SET Exit_Time = NOW() WHERE Vehicle_No = p_Vehicle_No;

        -- Get ticket & slot
        SELECT Ticket_ID, Slot_ID INTO v_Ticket_ID, v_Slot_ID
        FROM   TICKET WHERE Vehicle_No = p_Vehicle_No;

        -- Create transaction
        INSERT INTO TRANSACTION_LOG (Ticket_ID, Amount) VALUES (v_Ticket_ID, p_Amount);
        SET v_Trans_ID = LAST_INSERT_ID();

        -- Record payment
        INSERT INTO PAYMENT (Trans_ID, Method, Status) VALUES (v_Trans_ID, p_Method, 'Paid');

        -- Free the slot
        UPDATE PARKING_SLOT SET Is_Occupied = FALSE WHERE Slot_ID = v_Slot_ID;

        SET p_Message = CONCAT('SUCCESS: Fee = ₹', p_Amount, ' for ', v_Hours, ' hour(s). Slot ', v_Slot_ID, ' is now free.');
    END IF;
END$$


-- -----------------------------------------------------------------
-- SP 3: Generate full parking report for a date range
-- -----------------------------------------------------------------
CREATE PROCEDURE sp_ParkingReport(
    IN p_From DATE,
    IN p_To   DATE
)
BEGIN
    SELECT v.Vehicle_No, v.Model, v.Type,
           ua.Name         AS Owner,
           v.Arrival_Time,
           v.Exit_Time,
           TIMESTAMPDIFF(HOUR, v.Arrival_Time, IFNULL(v.Exit_Time, NOW())) AS Hours,
           COALESCE(tl.Amount, 0) AS Fee,
           COALESCE(p.Method, 'N/A')  AS Payment_Method,
           COALESCE(p.Status, 'Pending') AS Payment_Status
    FROM   VEHICLE          v
    JOIN   USER_ACCOUNT     ua ON v.User_ID     = ua.User_ID
    LEFT JOIN TICKET        tk ON v.Vehicle_No  = tk.Vehicle_No
    LEFT JOIN TRANSACTION_LOG tl ON tk.Ticket_ID = tl.Trans_ID
    LEFT JOIN PAYMENT       p  ON tl.Trans_ID   = p.Trans_ID
    WHERE  DATE(v.Arrival_Time) BETWEEN p_From AND p_To
    ORDER  BY v.Arrival_Time;
END$$


-- ============================================================
-- SECTION 5: PL/SQL – FUNCTIONS
-- ============================================================

-- -----------------------------------------------------------------
-- FN 1: Calculate parking fee given vehicle number
-- -----------------------------------------------------------------
CREATE FUNCTION fn_CalculateFee(p_Vehicle_No VARCHAR(20))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_Arrival DATETIME;
    DECLARE v_Exit    DATETIME;
    DECLARE v_Type    VARCHAR(20);
    DECLARE v_Hours   INT;
    DECLARE v_Rate    DECIMAL(10,2);

    SELECT Arrival_Time, Exit_Time, Type
    INTO   v_Arrival, v_Exit, v_Type
    FROM   VEHICLE WHERE Vehicle_No = p_Vehicle_No;

    SET v_Exit  = IFNULL(v_Exit, NOW());
    SET v_Hours = GREATEST(1, TIMESTAMPDIFF(HOUR, v_Arrival, v_Exit));

    SET v_Rate = CASE v_Type
                    WHEN 'Car'   THEN 20.00
                    WHEN 'Bike'  THEN 10.00
                    WHEN 'Truck' THEN 30.00
                    ELSE 15.00
                 END;

    RETURN v_Hours * v_Rate;
END$$


-- -----------------------------------------------------------------
-- FN 2: Return number of currently available slots
-- -----------------------------------------------------------------
CREATE FUNCTION fn_AvailableSlots()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_Count INT;
    SELECT COUNT(*) INTO v_Count FROM PARKING_SLOT WHERE Is_Occupied = FALSE;
    RETURN v_Count;
END$$


-- ============================================================
-- SECTION 6: PL/SQL – TRIGGERS
-- ============================================================

-- -----------------------------------------------------------------
-- TR 1: After a new TICKET is inserted, mark the slot occupied
-- -----------------------------------------------------------------
CREATE TRIGGER trg_AfterTicketInsert
AFTER INSERT ON TICKET
FOR EACH ROW
BEGIN
    UPDATE PARKING_SLOT
    SET    Is_Occupied = TRUE
    WHERE  Slot_ID = NEW.Slot_ID;
END$$


-- -----------------------------------------------------------------
-- TR 2: After VEHICLE exit_time is updated, free the slot
--        and validate exit is after arrival
-- -----------------------------------------------------------------
CREATE TRIGGER trg_BeforeVehicleUpdate
BEFORE UPDATE ON VEHICLE
FOR EACH ROW
BEGIN
    IF NEW.Exit_Time IS NOT NULL AND NEW.Exit_Time <= NEW.Arrival_Time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Exit time must be after arrival time.';
    END IF;
END$$


CREATE TRIGGER trg_AfterVehicleExit
AFTER UPDATE ON VEHICLE
FOR EACH ROW
BEGIN
    IF NEW.Exit_Time IS NOT NULL AND OLD.Exit_Time IS NULL THEN
        UPDATE PARKING_SLOT ps
        JOIN   TICKET tk ON ps.Slot_ID = tk.Slot_ID
        SET    ps.Is_Occupied = FALSE
        WHERE  tk.Vehicle_No = NEW.Vehicle_No;
    END IF;
END$$


-- -----------------------------------------------------------------
-- TR 3: Prevent inserting a ticket if slot is already occupied
-- -----------------------------------------------------------------
CREATE TRIGGER trg_BeforeTicketInsert
BEFORE INSERT ON TICKET
FOR EACH ROW
BEGIN
    DECLARE v_Occupied BOOLEAN;
    SELECT Is_Occupied INTO v_Occupied
    FROM   PARKING_SLOT WHERE Slot_ID = NEW.Slot_ID;

    IF v_Occupied = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Slot is already occupied. Choose a different slot.';
    END IF;
END$$


-- ============================================================
-- SECTION 7: PL/SQL – CURSORS (Report using cursor loop)
-- ============================================================

-- -----------------------------------------------------------------
-- Cursor example: Print all vehicles still in the parking lot
-- -----------------------------------------------------------------
CREATE PROCEDURE sp_CurrentVehiclesCursor()
BEGIN
    DECLARE v_done     BOOLEAN DEFAULT FALSE;
    DECLARE v_VehicleNo VARCHAR(20);
    DECLARE v_Model     VARCHAR(50);
    DECLARE v_Owner     VARCHAR(100);
    DECLARE v_Arrival   DATETIME;
    DECLARE v_Slot      INT;
    DECLARE v_HoursIn   INT;

    DECLARE cur_parked CURSOR FOR
        SELECT v.Vehicle_No, v.Model, ua.Name, v.Arrival_Time, tk.Slot_ID
        FROM   VEHICLE v
        JOIN   USER_ACCOUNT ua ON v.User_ID    = ua.User_ID
        JOIN   TICKET       tk ON v.Vehicle_No = tk.Vehicle_No
        WHERE  v.Exit_Time IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Temp result table
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_CurrentVehicles (
        Vehicle_No  VARCHAR(20),
        Model       VARCHAR(50),
        Owner       VARCHAR(100),
        Arrival     DATETIME,
        Slot_ID     INT,
        Hours_In    INT
    );
    DELETE FROM tmp_CurrentVehicles;

    OPEN cur_parked;

    read_loop: LOOP
        FETCH cur_parked INTO v_VehicleNo, v_Model, v_Owner, v_Arrival, v_Slot;
        IF v_done THEN LEAVE read_loop; END IF;

        SET v_HoursIn = TIMESTAMPDIFF(HOUR, v_Arrival, NOW());

        INSERT INTO tmp_CurrentVehicles
        VALUES (v_VehicleNo, v_Model, v_Owner, v_Arrival, v_Slot, v_HoursIn);
    END LOOP;

    CLOSE cur_parked;

    SELECT * FROM tmp_CurrentVehicles ORDER BY Hours_In DESC;
END$$


-- ============================================================
-- SECTION 8: EXCEPTION HANDLING EXAMPLE
-- ============================================================

-- -----------------------------------------------------------------
-- SP with full exception handling: Safe vehicle registration
-- -----------------------------------------------------------------
CREATE PROCEDURE sp_SafeRegisterVehicle(
    IN  p_Vehicle_No VARCHAR(20),
    IN  p_Model      VARCHAR(50),
    IN  p_Type       VARCHAR(20),
    IN  p_User_ID    INT,
    OUT p_Status     VARCHAR(200)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062         -- Duplicate entry
    BEGIN
        ROLLBACK;
        SET p_Status = 'ERROR: Vehicle already registered in the system.';
    END;

    DECLARE EXIT HANDLER FOR 1452         -- FK violation (User not found)
    BEGIN
        ROLLBACK;
        SET p_Status = 'ERROR: User ID does not exist. Please register the user first.';
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Status = 'ERROR: An unexpected error occurred. Transaction rolled back.';
    END;

    START TRANSACTION;

        INSERT INTO VEHICLE (Vehicle_No, Model, Type, Arrival_Time, User_ID)
        VALUES (p_Vehicle_No, p_Model, p_Type, NOW(), p_User_ID);

    COMMIT;
    SET p_Status = CONCAT('SUCCESS: Vehicle ', p_Vehicle_No, ' registered successfully.');
END$$


DELIMITER ;


-- ============================================================
-- SECTION 9: TRANSACTION MANAGEMENT DEMO
-- ============================================================

-- Demo: COMMIT / ROLLBACK / SAVEPOINT
START TRANSACTION;

    SAVEPOINT before_exit;

    -- Attempt to record vehicle exit
    UPDATE VEHICLE SET Exit_Time = NOW() WHERE Vehicle_No = 'PB10AB1234';

    -- If something is wrong, rollback to savepoint only
    -- ROLLBACK TO SAVEPOINT before_exit;

COMMIT;  -- Confirm the changes


-- ============================================================
-- SECTION 10: SAMPLE PROCEDURE CALLS (for testing)
-- ============================================================

-- Allocate a new slot
CALL sp_AllocateSlot('PB10KL1122', 'WagonR', 'Car', 3, @sid, @tid, @msg);
SELECT @sid AS Slot_Allocated, @tid AS Ticket_ID, @msg AS Result;

-- Process an exit
CALL sp_ProcessExit('PB10AB1234', 'Card', @fee, @msg);
SELECT @fee AS Fee_Charged, @msg AS Result;

-- Check fee for a vehicle still parked
SELECT fn_CalculateFee('PB10CD5678') AS Estimated_Fee;

-- Check available slots
SELECT fn_AvailableSlots() AS Free_Slots;

-- Parking report for today
CALL sp_ParkingReport(CURDATE(), CURDATE());

-- Current vehicles in lot (cursor-based)
CALL sp_CurrentVehiclesCursor();

-- Safe registration with exception handling
CALL sp_SafeRegisterVehicle('PB10AB1234', 'Swift', 'Car', 1, @status);
SELECT @status AS Registration_Status;  -- Should show duplicate error

-- View summary
SELECT * FROM vw_Parking_Summary;

-- ============================================================
-- END OF IMPLEMENTATION
-- ============================================================
