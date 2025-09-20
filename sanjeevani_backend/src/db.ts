import { Sequelize } from 'sequelize';

// Replace with your actual PostgreSQL password
export const sequelize = new Sequelize('sanjeevani_db', 'postgres', 'Vinay@140520', {
    host: 'localhost',
    dialect: 'postgres',
});

