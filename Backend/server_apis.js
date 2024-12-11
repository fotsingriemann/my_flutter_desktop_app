const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

const app = express();
const port = 3000;

// Configuration PostgreSQL
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'badging',
  password: 'admin',
  port: 5432,
});

// Middleware
app.use(bodyParser.json());

// Création de la table et insertion des données initiales
(async () => {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      rfid_code VARCHAR(255) NOT NULL UNIQUE,
      image TEXT NOT NULL
    )
  `);

  const initialData = [
    { name: 'Alice', rfid_code: '123456', image: 'https://via.placeholder.com/100' },
    { name: 'Bob', rfid_code: '654321', image: 'https://via.placeholder.com/100' },
    { name: 'Charlie', rfid_code: '789123', image: 'https://via.placeholder.com/100' },
  ];

  for (const user of initialData) {
    try {
      await pool.query(
        'INSERT INTO users (name, rfid_code, image) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING',
        [user.name, user.rfid_code, user.image]
      );
    } catch (error) {
      console.error(error);
    }
  }
})();

// API pour récupérer les données utilisateur
app.post('/get-user', async (req, res) => {
  const { rfidCode } = req.body;
  console.log(rfidCode)
  try {
    const result = await pool.query('SELECT * FROM users WHERE rfid_code = $1', [rfidCode]);
    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).send('Erreur interne du serveur');
  }
});

app.listen(port, () => {
  console.log(`Serveur démarré sur http://localhost:${port}`);
});
