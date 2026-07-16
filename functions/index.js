const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const bcrypt = require("bcryptjs");

admin.initializeApp();
const db = admin.firestore();

// =============================
// إعداد الإيميل المرسل منه OTP
// =============================
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "shruosh.shruosh@gmail.com",
    pass: "htaa pttg vhej qbrg", // مش باسورد الجيميل.. باسورد التطبيقات
  },
});

// =============================
// إرسال OTP
// =============================
exports.sendOTP = functions.https.onCall(async (data, context) => {
  const email = data.email;

  if (!email) throw new functions.https.HttpsError("invalid-argument", "email required");

  // توليد كود 6 أرقام
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  // تشفير الكود
  const hashed = await bcrypt.hash(otp, 10);

  // حفظه في Firestore
  await db.collection("otp_codes").doc(email).set({
    code: hashed,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // إرسال الإيميل
  await transporter.sendMail({
    from: "Meta Zone <YOUR_EMAIL@gmail.com>",
    to: email,
    subject: "Your MetaZone Verification Code",
    text: `Your verification code is ${otp}`,
  });

  return { success: true };
});

// =============================
// التحقق من OTP
// =============================
exports.verifyOTP = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const otp = data.otp;

  if (!email || !otp)
    throw new functions.https.HttpsError("invalid-argument", "Missing data");

  const doc = await db.collection("otp_codes").doc(email).get();
  if (!doc.exists) throw new functions.https.HttpsError("not-found", "OTP not found");

  const saved = doc.data();

  const valid = await bcrypt.compare(otp, saved.code);
  if (!valid) throw new functions.https.HttpsError("permission-denied", "Invalid code");

  // حذف الكود بعد الاستخدام
  await db.collection("otp_codes").doc(email).delete();

  return { success: true };
});
