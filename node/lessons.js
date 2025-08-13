// seedOnboardingQuestions.js
const { db } = require("./firebase");
const admin = require("firebase-admin");


async function seedFirestore() {
    const languageId = 'flutter';
  
    // 1. Language Document
    await db.collection('languages').doc(languageId).set({
      title: 'Flutter',
      icon: 'flutter.svg',
      totalUnits: 2,
      totalPoints: 1400,
    });
  
    const units = [
      {
        id: 'unit_1',
        title: 'Unit 1',
        description: 'Widgets & Basics',
        color: '#E57373',
        order: 1,
      },
      {
        id: 'unit_2',
        title: 'Unit 2',
        description: 'State Management',
        color: '#4CAF50',
        order: 2,
      },
    ];
  
    let allLessonIds = [];
  
    // 2. Create Units + Lessons
    for (const [unitIndex, unit] of units.entries()) {
      const unitLessonIds = [];
      for (let i = 1; i <= 7; i++) {
        const lessonId = `lesson_${unitIndex * 7 + i}`;
        unitLessonIds.push(lessonId);
        allLessonIds.push(lessonId);
  
        await db.collection('chapters').doc(lessonId).set({
          id: lessonId,
          title: `Lesson ${unitIndex * 7 + i}: ${unitIndex === 0 ? 'Widgets' : 'State'} Topic`,
          unitId: unit.id,
          language: languageId,
          points: Math.floor(Math.random() * 100 + 50),
          type: i % 5 === 0 ? 'bonus' : 'normal',
          isBonus: i % 5 === 0,
        });
  
        // 3. Add Questions
        const questions = [
          {
            id: `${lessonId}_q1`,
            lessonId,
            question: `What is the main concept of ${lessonId}?`,
            options: ['Concept A', 'Concept B', 'Concept C', 'Concept D'],
            answerIndex: 1,
            explanation: 'This is a placeholder explanation.',
          },
          {
            id: `${lessonId}_q2`,
            lessonId,
            question: `Which widget fits ${lessonId} best?`,
            options: ['Widget A', 'Widget B', 'Widget C'],
            answerIndex: 0,
            explanation: 'Basic widget selection.',
          },
        ];
  
        for (const q of questions) {
          await db.collection('questions').doc(q.id).set(q);
        }
      }
  
      // Store Unit
      await db
        .collection('languages')
        .doc(languageId)
        .collection('units')
        .doc(unit.id)
        .set({
          ...unit,
          lessons: unitLessonIds,
        });
    }
  
    console.log(`✅ Seeded ${units.length} units, ${allLessonIds.length} lessons, and ${allLessonIds.length * 2} questions`);
  }
  
  seedFirestore();
  