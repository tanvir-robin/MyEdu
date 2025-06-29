// Sample data for testing the Academic Fees feature
// This file contains sample data structure that should be added to Firestore

/*
To add sample data to your Firestore 'academic_fees' collection, use the following structure:

Collection: academic_fees

Document 1 (Shows for All):
{
  "purpose": "Semester Tuition Fee",
  "amount": 25000,
  "deadline": "2025-06-15T00:00:00Z", // Use Firestore Timestamp
  "createdAt": "2025-05-01T00:00:00Z", // Use Firestore Timestamp
  "status": "pending",
  "type": "tuition",
  "description": "Tuition fee for Spring 2025 semester",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": true,
  "applicableFaculties": ["Computer Science", "Engineering", "Business"],
  "lateFee": 500,
  "discount": null,
  "targetType": "All",
  "targetValue": "",
  "items": [
    {
      "name": "Course Registration",
      "amount": 15000,
      "description": "Registration for all courses"
    },
    {
      "name": "Laboratory Access",
      "amount": 5000,
      "description": "Access to computer labs and equipment"
    },
    {
      "name": "Library Services",
      "amount": 3000,
      "description": "Digital and physical library access"
    },
    {
      "name": "Student Activities",
      "amount": 2000,
      "description": "Clubs, events, and extracurricular activities"
    }
  ]
}

Document 2 (Shows for 6th):
{
  "purpose": "Registration Fee",
  "amount": 2000,
  "deadline": "2025-05-30T00:00:00Z",
  "createdAt": "2025-05-01T00:00:00Z",
  "status": "pending",
  "type": "registration",
  "description": "Annual registration fee for 2025",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": false,
  "applicableFaculties": [],
  "lateFee": 200,
  "discount": null,
  "targetType": "Class",
  "targetValue": "6th",
  "items": [
    {
      "name": "Student ID Card",
      "amount": 500,
      "description": "New student identification card"
    },
    {
      "name": "Academic Records",
      "amount": 800,
      "description": "Transcript and certificate processing"
    },
    {
      "name": "Administrative Fee",
      "amount": 700,
      "description": "General administrative processing"
    }
  ]
}

Document 3 (Shows for 20-21):
{
  "purpose": "Library Fee",
  "amount": 1500,
  "deadline": "2025-05-20T00:00:00Z", // Overdue date for testing
  "createdAt": "2025-04-01T00:00:00Z",
  "status": "pending",
  "type": "library",
  "description": "Annual library access and maintenance fee",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": true,
  "applicableFaculties": [],
  "lateFee": 150,
  "discount": null,
  "targetType": "Year",
  "targetValue": "20-21",
  "items": [
    {
      "name": "Digital Library Access",
      "amount": 800,
      "description": "Online journals, e-books, and databases"
    },
    {
      "name": "Physical Library Services",
      "amount": 500,
      "description": "Book borrowing and reading room access"
    },
    {
      "name": "Printing & Photocopying",
      "amount": 200,
      "description": "Library printing and copying services"
    }
  ]
}

Document 4 (Shows for 6th):
{
  "purpose": "Lab Fee - Chemistry",
  "amount": 3000,
  "deadline": "2025-07-01T00:00:00Z",
  "createdAt": "2025-05-01T00:00:00Z",
  "status": "paid",
  "type": "laboratory",
  "description": "Laboratory fee for Chemistry practical sessions",
  "receiptNumber": "RCP1716720000000",
  "paidAt": "2025-05-15T10:30:00Z",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": false,
  "applicableFaculties": ["Chemistry", "Biochemistry"],
  "lateFee": null,
  "discount": 300,
  "targetType": "Class",
  "targetValue": "6th",
  "items": [
    {
      "name": "Lab Equipment Usage",
      "amount": 1500,
      "description": "Access to specialized chemistry equipment"
    },
    {
      "name": "Chemical Supplies",
      "amount": 1000,
      "description": "Reagents and consumables for experiments"
    },
    {
      "name": "Safety Equipment",
      "amount": 500,
      "description": "Protective gear and safety equipment"
    }
  ]
}

Document 5 (Shows for 20-21):
{
  "purpose": "Sports Fee",
  "amount": 800,
  "deadline": "2025-06-10T00:00:00Z",
  "createdAt": "2025-05-01T00:00:00Z",
  "status": "pending",
  "type": "sports",
  "description": "Annual sports and recreational activities fee",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": true,
  "applicableFaculties": [],
  "lateFee": 100,
  "discount": null,
  "targetType": "Year",
  "targetValue": "20-21",
  "items": [
    {
      "name": "Gym Membership",
      "amount": 400,
      "description": "Access to fitness center and gym equipment"
    },
    {
      "name": "Sports Equipment",
      "amount": 250,
      "description": "Access to sports equipment and gear"
    },
    {
      "name": "Tournament Participation",
      "amount": 150,
      "description": "Inter-university sports competitions"
    }
  ]
}

Document 6 (Will NOT show - targetValue doesn't match criteria):
{
  "purpose": "Development Fee",
  "amount": 5000,
  "deadline": "2025-06-30T00:00:00Z",
  "createdAt": "2025-05-01T00:00:00Z",
  "status": "pending",
  "type": "development",
  "description": "Infrastructure development and maintenance fee",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": true,
  "applicableFaculties": [],
  "lateFee": 1000,
  "discount": null,
  "targetType": "Class",
  "targetValue": "7th", // This will NOT show because it's not '6th' or '20-21'
  "items": [
    {
      "name": "Building Maintenance",
      "amount": 2000,
      "description": "Maintenance and upkeep of campus buildings"
    },
    {
      "name": "Technology Infrastructure",
      "amount": 1500,
      "description": "IT systems and network infrastructure"
    },
    {
      "name": "Campus Beautification",
      "amount": 1000,
      "description": "Landscaping and campus improvement"
    },
    {
      "name": "Security Systems",
      "amount": 500,
      "description": "Campus security and surveillance"
    }
  ]
}

Document 7 (Shows for specific student with ID "2002010"):
{
  "purpose": "Late Fee - Special Assessment",
  "amount": 2500,
  "deadline": "2025-06-20T00:00:00Z",
  "createdAt": "2025-05-15T00:00:00Z",
  "status": "pending",
  "type": "miscellaneous",
  "description": "Special assessment fee for late submission of documents",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": false,
  "applicableFaculties": [],
  "lateFee": 500,
  "discount": null,
  "targetType": "Individual",
  "targetValue": "2002010", // This will show ONLY for student with ID "2002010"
  "items": [
    {
      "name": "Document Processing",
      "amount": 1500,
      "description": "Processing fee for late document submission"
    },
    {
      "name": "Administrative Penalty",
      "amount": 1000,
      "description": "Penalty for late submission"
    }
  ]
}

Document 8 (Shows for specific student with ID "2002011"):
{
  "purpose": "Outstanding Library Fine",
  "amount": 800,
  "deadline": "2025-06-25T00:00:00Z",
  "createdAt": "2025-05-20T00:00:00Z",
  "status": "pending",
  "type": "miscellaneous",
  "description": "Outstanding fine for overdue library books",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": false,
  "applicableFaculties": [],
  "lateFee": 100,
  "discount": null,
  "targetType": "Individual",
  "targetValue": "2002011", // This will show ONLY for student with ID "2002011"
  "items": [
    {
      "name": "Overdue Book Fine",
      "amount": 600,
      "description": "Fine for overdue library books"
    },
    {
      "name": "Processing Fee",
      "amount": 200,
      "description": "Administrative processing fee"
    }
  ]
}

FILTERING LOGIC:
- If targetType == 'All': Show the bill to everyone
- If targetType == 'Individual' AND targetValue == user's academic ID: Show only to that specific student
- If targetType != 'All' AND targetType != 'Individual' AND targetValue == '6th' OR targetValue == '20-21': Show the bill  
- Otherwise: Do NOT show the bill

To add this data:
1. Go to Firebase Console
2. Navigate to your Firestore Database
3. Create a collection named 'academic_fees'
4. Add documents with the above data structure
5. Make sure to convert date strings to Firestore Timestamps
6. The 'items' field should be an array of objects with name, amount, and optional description
7. Add the new 'targetType' and 'targetValue' fields for filtering
8. For Individual fees, set targetValue to the specific student's academic ID
*/
