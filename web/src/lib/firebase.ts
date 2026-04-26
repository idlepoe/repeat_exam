import { getApp, getApps, initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'

const firebaseConfig = {
  apiKey: 'AIzaSyBglJxatZGtYQowv4jK7mp2m6swG10zbjw',
  authDomain: 'repeat-exam.firebaseapp.com',
  projectId: 'repeat-exam',
  storageBucket: 'repeat-exam.firebasestorage.app',
  messagingSenderId: '586008015901',
  appId: '1:586008015901:web:b12882bed157f628a542f4',
  measurementId: 'G-Q04DW43HYJ',
}

const app = getApps().length ? getApp() : initializeApp(firebaseConfig)

export const db = getFirestore(app)
