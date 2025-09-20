import { Router } from 'express';
import { sequelize } from '../db';

const router = Router();

// Endpoint to CREATE a new prescription
router.post('/create', async (req, res) => {
    // We expect the app to send all the necessary IDs and the prescription details
    const { appointmentId, patientId, doctorId, medicines, notes } = req.body;

    // Basic validation
    if (!appointmentId || !patientId || !doctorId || !medicines) {
        return res.status(400).json({ message: 'Missing required fields for prescription.' });
    }

    try {
        const query = `
            INSERT INTO "Prescriptions" ("appointmentId", "patientId", "doctorId", "medicines", "notes", "createdAt", "updatedAt") 
            VALUES ($1, $2, $3, $4, $5, NOW(), NOW()) 
            RETURNING *
        `;
        // We use JSON.stringify to properly format the list of medicines for the JSONB column
        const values = [appointmentId, patientId, doctorId, JSON.stringify(medicines), notes || ''];
        
        const [newPrescription] = (await sequelize.query(query, { bind: values }))[0];

        res.status(201).json({ message: 'Prescription created successfully!', prescription: newPrescription });
    } catch (error) {
        console.error('Error creating prescription:', error);
        res.status(500).json({ message: 'Failed to create prescription', error });
    }
});

// Endpoint to GET all prescriptions for a patient
router.get('/patient/:patientId', async (req, res) => {
    const { patientId } = req.params;

    try {
        const query = 'SELECT * FROM "Prescriptions" WHERE "patientId" = $1 ORDER BY "createdAt" DESC';
        const prescriptions = await sequelize.query(query, {
            bind: [patientId],
            type: 'SELECT'
        });

        res.status(200).json(prescriptions);
    } catch (error) {
        console.error('Error fetching prescriptions:', error);
        res.status(500).json({ message: 'Failed to fetch prescriptions', error });
    }
});

export default router;
