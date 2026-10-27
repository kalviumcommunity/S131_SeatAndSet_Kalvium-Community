const { test, before, after, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'seatandset-1',
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

beforeEach(async () => {
  if (testEnv) {
    await testEnv.clearFirestore();
  }
});

test('denies unauthenticated users from reading furniture', async () => {
  const unauthContext = testEnv.unauthenticatedContext();
  const db = unauthContext.firestore();
  await assertFails(db.collection('furniture').get());
});

test('allows signed-in customer to read furniture', async () => {
  const userContext = testEnv.authenticatedContext('cust123');
  const db = userContext.firestore();
  await assertSucceeds(db.collection('furniture').get());
});

test('allows customer to create and read their own customer profile', async () => {
  const userContext = testEnv.authenticatedContext('cust123');
  const db = userContext.firestore();

  await assertSucceeds(
    db.collection('customers').doc('cust123').set({
      name: 'Rahul Sharma',
      phoneNumber: '+91 98765 43210',
      email: 'rahul@example.com',
      createdAt: new Date(),
      updatedAt: new Date(),
    })
  );

  await assertSucceeds(db.collection('customers').doc('cust123').get());
});

test('denies customer from reading another customer profile', async () => {
  const userContext = testEnv.authenticatedContext('cust123');
  const db = userContext.firestore();
  await assertFails(db.collection('customers').doc('other_user').get());
});

test('denies customer from directly creating booking documents in Firestore', async () => {
  const userContext = testEnv.authenticatedContext('cust123');
  const db = userContext.firestore();

  await assertFails(
    db.collection('bookings').add({
      customerId: 'cust123',
      furnitureId: 'f1',
      startDate: new Date(),
      endDate: new Date(Date.now() + 86400000),
      status: 'reserved',
      createdAt: new Date(),
      updatedAt: new Date(),
    })
  );
});

test('allows customer to cancel their own existing reserved booking', async () => {
  // First seed a reserved booking as admin
  const adminContext = testEnv.authenticatedContext('admin123', {
    admin: true,
  });
  const adminDb = adminContext.firestore();
  const bookingRef = adminDb.collection('bookings').doc('booking123');

  const now = new Date();
  const later = new Date(Date.now() + 86400000);

  await adminRef(bookingRef, {
    customerId: 'cust123',
    furnitureId: 'f1',
    startDate: now,
    endDate: later,
    status: 'reserved',
    createdAt: now,
    updatedAt: now,
  });

  // Now test customer cancelling the booking
  const customerContext = testEnv.authenticatedContext('cust123');
  const customerDb = customerContext.firestore();

  await assertSucceeds(
    customerDb.collection('bookings').doc('booking123').update({
      status: 'cancelled',
      updatedAt: new Date(),
    })
  );
});

test('denies customer from arbitrarily modifying booking dates or fields', async () => {
  const adminContext = testEnv.authenticatedContext('admin123', {
    admin: true,
  });
  const adminDb = adminContext.firestore();
  const bookingRef = adminDb.collection('bookings').doc('booking123');

  const now = new Date();
  const later = new Date(Date.now() + 86400000);

  await adminRef(bookingRef, {
    customerId: 'cust123',
    furnitureId: 'f1',
    startDate: now,
    endDate: later,
    status: 'reserved',
    createdAt: now,
    updatedAt: now,
  });

  const customerContext = testEnv.authenticatedContext('cust123');
  const customerDb = customerContext.firestore();

  // Attempting to change dates
  await assertFails(
    customerDb.collection('bookings').doc('booking123').update({
      endDate: new Date(Date.now() + 86400000 * 10),
      updatedAt: new Date(),
    })
  );
});

test('denies customer from directly writing to furniture_booking_locks', async () => {
  const userContext = testEnv.authenticatedContext('cust123');
  const db = userContext.firestore();

  await assertFails(
    db.collection('furniture_booking_locks').doc('f1').set({
      furnitureId: 'f1',
      reservations: {},
      updatedAt: new Date(),
    })
  );
});

test('allows admin users with admin claim to write furniture, bookings, and locks', async () => {
  const adminContext = testEnv.authenticatedContext('admin123', {
    admin: true,
  });
  const db = adminContext.firestore();

  await assertSucceeds(
    db.collection('furniture').doc('SOFA001').set({
      name: 'Modern Sofa',
      sku: 'SOFA001',
      status: 'available',
      type: 'sofa',
      createdAt: new Date(),
      updatedAt: new Date(),
    })
  );

  await assertSucceeds(
    db.collection('furniture_booking_locks').doc('SOFA001').set({
      furnitureId: 'SOFA001',
      reservations: {},
      updatedAt: new Date(),
    })
  );
});

async function adminRef(ref, data) {
  await ref.set(data);
}
