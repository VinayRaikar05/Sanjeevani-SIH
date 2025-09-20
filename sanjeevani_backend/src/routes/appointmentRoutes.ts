import { Router } from 'express';
import { sequelize } from '../db';

const router = Router();

// This endpoint fetches all appointments for a specific doctor's ID.
// It also joins with the "Users" table to get the patient's name.
router.get('/doctor/:doctorId', async (req, res) => {
    const { doctorId } = req.params;

    try {
        const query = `
            SELECT 
                A.id, 
                A."patientId", 
                A."doctorId", 
                A.timeslot, 
                A.status, 
                A."createdAt",
                P.name AS "patientName" 
            FROM 
                "Appointments" AS A
            INNER JOIN 
                "Users" AS P ON A."patientId" = P.id
            WHERE 
                A."doctorId" = $1 
            ORDER BY 
                A."createdAt" DESC
        `;
        const appointments = await sequelize.query(query, {
            bind: [doctorId],
            type: 'SELECT'
        });
        res.status(200).json(appointments);
    } catch (error) {
        console.error('Error fetching doctor appointments:', error);
        res.status(500).json({ message: 'Failed to fetch appointments', error });
    }
});


// This endpoint for booking an appointment remains the same.
router.post('/book', async (req, res) => {
    const { doctorId, timeslot, patientId } = req.body;
    if (!doctorId || !timeslot || !patientId) {
        return res.status(400).json({ message: 'Missing required fields' });
    }
    try {
        const query = `INSERT INTO "Appointments" ("doctorId", "timeslot", "patientId", "createdAt", "updatedAt") VALUES ($1, $2, $3, NOW(), NOW()) RETURNING *`;
        const values = [doctorId, timeslot, patientId];
        const [newAppointment] = (await sequelize.query(query, { bind: values }))[0];
        res.status(201).json({ status: 'success', message: 'Appointment booked successfully!', data: newAppointment });
    } catch (error) {
        console.error('Error booking appointment:', error);
        res.status(500).json({ message: 'Error booking appointment', error });
    }
});

export default router;

