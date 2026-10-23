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

test('denies non-admin authenticated users from reading furniture', async () => {
  const userContext = testEnv.authenticatedContext('user123', {
    admin: false,
  });
  const db = userContext.firestore();
  await assertFails(db.collection('furniture').get());
});

test('allows admin users with admin claim to read and write valid furniture', async () => {
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

  await assertSucceeds(db.collection('furniture').doc('SOFA001').get());
});

test('denies creating furniture with invalid schema or unknown fields', async () => {
  const adminContext = testEnv.authenticatedContext('admin123', {
    admin: true,
  });
  const db = adminContext.firestore();

  await assertFails(
    db.collection('furniture').doc('INVALID').set({
      name: 'Invalid Sofa',
      status: 'available',
      type: 'sofa',
      createdAt: new Date(),
      updatedAt: new Date(),
    })
  );
});

test('denies unauthenticated users from creating bookings', async () => {
  const unauthContext = testEnv.unauthenticatedContext();
  const db = unauthContext.firestore();
  await assertFails(
    db.collection('bookings').add({
      customerId: 'c1',
      furnitureId: 'f1',
      startDate: new Date(),
      endDate: new Date(Date.now() + 86400000),
      status: 'reserved',
      createdAt: new Date(),
      updatedAt: new Date(),
    })
  );
});
