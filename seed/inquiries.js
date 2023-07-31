const { Client } = require('pg');
const {faker} = require('@faker-js/faker');

const connectionString = 'postgres://alekinho:alekinho123@localhost:5430/alekinho';
const client = new Client({ connectionString });
async function seedInquiriesTable() {
  try {
    await client.connect();

    let iteration = 0;
    while (true) {
      const user_id = faker.number.int({ min: 1, max: 1000 })
      const inquiry_date = faker.date.between({ from: '2023-08-01', to: '2023-08-31'});
      const message = faker.lorem.sentence();
      await client.query(
        'INSERT INTO inquiries (user_id, inquiry_date, message) VALUES ($1, $2, $3)',
        [user_id, inquiry_date, message]
      );

      iteration++;
      console.log(`Inserted inquiry #${iteration}`);
    }
  } catch (err) {
    console.error('Error seeding inquiries:', err);
  } finally {
    client.end();
  }
}

seedInquiriesTable();