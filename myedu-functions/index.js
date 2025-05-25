const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const firestore = admin.firestore();

// Topic name for push notifications
const TOPIC = "pn";

// Trigger for notices collection
exports.onNewNoticeCreated = functions.firestore
  .document("notices/{noticeId}")
  .onCreate(async (snap, context) => {
    const newDoc = snap.data();
    const title = newDoc.title || "New Notice";
    const content = newDoc.content || "";

    // Send push notification
    await admin.messaging().send({
      topic: TOPIC,
      notification: {
        title: title,
        body: content,
      },
    });

    // Save to notifications collection
    await firestore.collection("notifications").add({
      title: title,
      content: content,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      type: "notice",
    });
  });

// Trigger for academic_fees collection
exports.onNewAcademicFeeCreated = functions.firestore
  .document("academic_fees/{feeId}")
  .onCreate(async (snap, context) => {
    const newDoc = snap.data();
    const purpose = newDoc.purpose || "Academic Fee";
    const total = newDoc.total || 0;

    const title = `${purpose} - ${total} TK`;
    const content = "You have a new bill ready";

    // Send push notification
    await admin.messaging().send({
      topic: TOPIC,
      notification: {
        title: title,
        body: content,
      },
    });

    // Save to notifications collection
    await firestore.collection("notifications").add({
      title: title,
      content: content,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      type: "academic_fee",
    });
  });
