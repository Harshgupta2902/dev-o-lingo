// seedOnboardingQuestions.js
const { db } = require("./firebase");
const admin = require("firebase-admin");


async function setUserProgress() {
    const userId = '117735150970465752256';
    const lessonId = 'lesson_3';

    await db.collection('user_progress')
        .doc(userId)
        .collection('progress')
        .doc('flutter_progress')
        .set({
            lastCompletedLessonId: lessonId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

    console.log(`✅ Set progress for ${userId} up to ${lessonId}`);
}

setUserProgress();
