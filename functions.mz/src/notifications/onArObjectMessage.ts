import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin";
import {
  getFirestore,
  FieldValue,
} from "firebase-admin/firestore";


initializeApp();
const db = getFirestore();

/**
 * =====================================
 * AR OBJECT CHAT
 * - Auto Moderation
 * - Notify Followers
 * - Safe Stats Update
 * =====================================
 */
export const onArObjectMessage = onDocumentCreated(
  "chat_contexts/{contextId}/messages/{messageId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const contextId = event.params.contextId;
    if (!data || !contextId) return;

    // 🧠 تجاهل غير النص
    if (data.type !== "TEXT") return;

    // 🔍 تحميل الـ context
    const ctxRef = db.doc(`chat_contexts/${contextId}`);
    const ctxSnap = await ctxRef.get();
    if (!ctxSnap.exists) return;

    const ctx = ctxSnap.data();
    if (ctx?.type !== "AR_OBJECT") return;

    const objectId = ctx.owner?.refId;
    if (!objectId) return;

    const text: string = data.payload?.text ?? "";
    const senderId: string | null = data.sender?.userId ?? null;

    /* ============================
       AUTO MODERATION (BASIC)
    ============================ */
    const bannedWords = ["spam", "scam", "hack"];
    const isFlagged = bannedWords.some(w =>
      text.toLowerCase().includes(w)
    );

    if (isFlagged) {
      await snap.ref.set({
        moderation: {
          hidden: true,
          autoAction: "AUTO_FLAGGED",
          reason: "BANNED_KEYWORD"
        }
      }, { merge: true });
    }

    /* ============================
       UPDATE CONTEXT STATS
    ============================ */
    await ctxRef.set({
      stats: {
     messagesCount: FieldValue.increment(1),
     lastActivityAt: FieldValue.serverTimestamp(),

      }
    }, { merge: true });

    /* ============================
       NOTIFY AR OBJECT FOLLOWERS
    ============================ */
    const followersSnap = await db
      .collection("ar_object_follows")
      .doc(objectId)
      .collection("followers")
      .get();

    if (followersSnap.empty) return;

    const batch = db.batch();
const now = FieldValue.serverTimestamp();

    for (const doc of followersSnap.docs) {
      const followerId = doc.id;

      // مايبعتش لنفسه
      if (followerId === senderId) continue;

      const notifRef = db
        .collection("users")
        .doc(followerId)
        .collection("notifications")
        .doc();

      batch.set(notifRef, {
        type: "AR_OBJECT_NEW_COMMENT",
        contextId,
        messageId: snap.id,
        text,
        fromUserId: senderId,
        createdAt: now,
        read: false,
      });
    }

    await batch.commit();
  }
);
