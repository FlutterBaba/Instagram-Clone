const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore.document("/followers/{userId}/{userFollowers}")
    .onCreate(async (snapshort, context) => {
        console.log("Follower Created ", snapshort.data());

        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const followedUserPostsRef = admin.firestore()
            .collection("posts")
            .doc(userId).collection("userPosts");
        const timelinePostsRef = admin.firestore()
            .collection("timeline")
            .doc(followerId).collection("timelinePosts");
        const querySnapshort = await followedUserPostsRef.get();
        querySnapshort.forEach(doc => {
            if (doc.exists) {
                const psotId = doc.id;
                const postData = doc.data();

                timelinePostsRef.doc(psotId).set(postData);
            }
        })

    }
    )