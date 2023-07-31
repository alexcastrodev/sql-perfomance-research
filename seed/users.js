const { Client } = require('pg');
const {faker} = require('@faker-js/faker');

const connectionString = 'postgres://alekinho:alekinho123@localhost:5430/alekinho';
const client = new Client({ connectionString });
async function seedUserTable() {
  try {
    await client.connect();

    let iteration = 0;
    while (iteration <= 1000) {  
        const username = faker.person.firstName();
        const email = faker.internet.email();
        const password = faker.internet.password();

        await client.query(
        'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)',
        [username, email, password]
      );

      iteration++;
      console.log(`Inserted user #${iteration}`);

      await new Promise(resolve => setTimeout(resolve, 1));
    }
  } catch (err) {
    console.error('Error seeding user:', err);
  } finally {
    client.end();
  }
}

seedUserTable();