import { Router } from 'express';
import admin from 'firebase-admin';
import { sequelize } from '../db';

const router = Router();

// This endpoint is our main login gateway. It's now much smarter.
router.post('/verify-otp', async (req, res) => {
    const { idToken } = req.body;
    if (!idToken) { return res.status(400).json({ message: 'ID token is required.' }); }

    try {
        // Step 1: Securely verify the token from the app with Firebase.
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const phoneNumber = decodedToken.phone_number;
        if (!phoneNumber) { return res.status(400).json({ message: 'Phone number not found in token.' }); }

        // Step 2: Check if a user with this phone number already exists in our database.
        const userList: any[] = await sequelize.query(
            'SELECT * FROM "Users" WHERE "phoneNumber" = $1', 
            { bind: [phoneNumber], type: 'SELECT' }
        );
        
        let user: any;
        let isNewUser = false; // This is a flag we will send back to the app.

        if (userList.length > 0) {
            // If the user exists, we get their data from the database.
            user = userList[0];
        } else {
            // If the user does NOT exist, they are a new user.
            isNewUser = true; // Set the flag to true.
            // We create their record with a temporary 'UNKNOWN' role.
            const newUserQuery: any[] = await sequelize.query(
                'INSERT INTO "Users" ("phoneNumber", "name", "role", "createdAt", "updatedAt") VALUES ($1, $2, $3, NOW(), NOW()) RETURNING *', 
                { bind: [phoneNumber, 'New User', 'UNKNOWN'], type: 'INSERT' }
            );
            user = newUserQuery[0][0];
        }
        
        console.log('User login attempt:', user);
        // Step 3: Send back the user's data AND the important isNewUser flag to the Flutter app.
        res.status(200).json({ message: 'Login successful!', user: user, isNewUser: isNewUser });

    } catch (error) {
        console.error('Authentication failed:', error);
        res.status(401).json({ message: 'Authentication failed.', error });
    }
});

// This is a brand new endpoint for setting the role after the first login.
router.post('/set-role', async (req, res) => {
    const { phoneNumber, role, name } = req.body;

    // We do some validation to make sure the data from the app is correct.
    if (!phoneNumber || !role || !name) {
        return res.status(400).json({ message: 'Phone number, role, and name are required.' });
    }
    if (role !== 'PATIENT' && role !== 'DOCTOR') {
        return res.status(400).json({ message: 'Invalid role specified.' });
    }

    try {
        // This command finds the user by their phone number and updates their name and role.
        await sequelize.query(
            'UPDATE "Users" SET "role" = $1, "name" = $2 WHERE "phoneNumber" = $3',
            { bind: [role, name, phoneNumber], type: 'UPDATE' }
        );

        res.status(200).json({ message: 'Role set successfully!' });
    } catch (error) {
        console.error('Error setting user role:', error);
        res.status(500).json({ message: 'Failed to set user role', error });
    }
});

export default router;

