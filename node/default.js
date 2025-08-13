// seedOnboardingQuestions.js
const { db } = require("./firebase");
const admin = require("firebase-admin");


async function uploadQuestions() {
    const defaultData = {
      bonusGems: 100,
      bonusLives: 5,
      version: '1.0.1',
      build: 12,
      avatarsList: [],
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
  
    try {
      await db.collection('config').doc('defaultData').set(defaultData, { merge: true });
      console.log("✅ Default onboarding data uploaded successfully.");
    } catch (error) {
      console.error("❌ Error uploading onboarding data:", error);
    }
  }
  
  uploadQuestions();