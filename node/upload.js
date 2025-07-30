// seedOnboardingQuestions.js
const { db } = require("./firebase");
const admin = require("firebase-admin");

const onboardingQuestions = [
    {
        key: "learningLanguage",
        question: "Which programming language would you like to learn?",
        options: [
            { name: "JavaScript", flag: "🟨", color: '0xFFF7DF1E' },
            { name: "Python", flag: "🐍", color: '0xFF3776AB' },
            { name: "C++", flag: "💻", color: '0xFF00599C' },
            { name: "Java", flag: "☕️", color: '0xFFED8B00' },
            { name: "Go", flag: "🐹", color: '0xFF00ADD8' },
            { name: "Rust", flag: "🦀", color: '0xFF000000' },
        ],
    },
    {
        key: "discoverySource",
        question: "How did you discover DevLingo?",
        options: [
            { name: "GitHub", flag: "🐙", color: '0xFF181717' },
            { name: "Twitter", flag: "🐦", color: '0xFF1DA1F2' },
            { name: "Reddit", flag: "👽", color: '0xFFFF4500' },
            { name: "Friend", flag: "🤝", color: '0xFF4CAF50' },
            { name: "Google", flag: "🔍", color: '0xFF4285F4' },
        ],
    },
    {
        key: "proficiency",
        question: "What's your current experience level?",
        options: [
            { name: "Total beginner", flag: "🌱", color: '0xFF8BC34A' },
            { name: "Basic syntax", flag: "🧩", color: '0xFF2196F3' },
            { name: "Can build small apps", flag: "🔧", color: '0xFFFF9800' },
            { name: "Intermediate+", flag: "🚀", color: '0xFF9C27B0' },
        ],
    },
    {
        key: "motivation",
        question: "Why do you want to learn coding?",
        options: [
            { name: "For a job", flag: "💼", color: '0xFF607D8B' },
            { name: "To build projects", flag: "🛠️", color: '0xFFFF5722' },
            { name: "Just exploring", flag: "🔍", color: '0xFF795548' },
            { name: "Startup dreams", flag: "🚀", color: '0xFFE91E63' },
        ],
    },
    {
        key: "studyTarget",
        question: "What's your daily coding goal?",
        options: [
            { name: "5 mins", flag: "⏰", color: '0xFF4CAF50' },
            { name: "10 mins", flag: "⏰", color: '0xFF2196F3' },
            { name: "15 mins", flag: "⏰", color: '0xFFFF9800' },
            { name: "30 mins", flag: "⏰", color: '0xFF9C27B0' },
            { name: "60 mins", flag: "⏰", color: '0xFFF44336' },
        ],
    },
];

async function uploadQuestions() {
    try {
        await db.collection('onboarding').doc('questions').set({
            questions: onboardingQuestions,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          }, { merge: true });
        console.log("✅ Onboarding questions uploaded successfully.");
    } catch (error) {
        console.error("❌ Error uploading questions:", error);
    }
}

uploadQuestions();
