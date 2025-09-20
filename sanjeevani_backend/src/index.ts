import express from 'express';
import cors from 'cors';
import { sequelize } from './db';
import admin from 'firebase-admin';
import prescriptionRoutes from './routes/prescriptionRoutes';

// These paths mean "look inside the 'routes' folder which is in the same directory as this file".
import doctorRoutes from './routes/doctorRoutes';
import appointmentRoutes from './routes/appointmentRoutes';
import authRoutes from './routes/authRoutes';

// This line has been corrected. It now correctly goes up only ONE level to find the file.
const serviceAccount = require('../serviceAccountKey.json'); 

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to allow cross-origin requests and parse JSON bodies
app.use(cors());
app.use(express.json());

// --- API Routes ---
app.use('/api/auth', authRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/prescriptions', prescriptionRoutes);

// --- Server Startup Logic ---
const startServer = async () => {
    try {
        // Test the database connection first
        await sequelize.authenticate();
        console.log('Database connection has been established successfully.');
        
        // If the database connection is successful, start the web server
        app.listen(PORT, () => {
            console.log(`Server is running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Unable to connect to the database:', error);
    }
};

startServer();


