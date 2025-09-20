import { Router } from 'express';
// This path now correctly says "go up one level" to find db.ts
import { sequelize } from '../db';

const router = Router();

router.get('/', async (req, res) => {
    try {
        const [results] = await sequelize.query('SELECT * FROM "Doctors"');
        res.json(results);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching doctors', error });
    }
});

export default router;

