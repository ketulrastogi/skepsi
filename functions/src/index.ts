import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const firebase = admin.initializeApp();

export const createProfile = functions.auth.user().onCreate((user) => {

    return admin.firestore().collection('users').doc(user.uid).set({
        'id': user.uid,
        'phoneNumber': user.phoneNumber
    });
});

export const createRole = functions.auth.user().onCreate((user) => {
    return admin.firestore().collection('roles').doc(user.uid).set({
        'id': user.uid,
        'phoneNumber': user.phoneNumber,
        'member': true
    });

});

export const notifyUserForNewQuote = functions.firestore.document('quotes/{quoteId}').onCreate((snap, context) => {
    const newQuote = snap.data();

    const payload = {
        notification: {
            title: `${newQuote['quote']}.`,
            body: `${newQuote['author']}.`
        },
    };

    return admin.messaging().sendToTopic('quotes', payload);

});

exports.deleteQuote = functions.firestore
    .document('quotes/{quoteId}')
    .onDelete((snap, context) => {
        // Get an object representing the document prior to deletion
        // e.g. {'name': 'Marie', 'age': 66}
        const deletedValue = snap.data();
        const path = deletedValue['imageFBPath'];
        const bucket = firebase.storage().bucket('skepsi-quotes-app.appspot.com');
        return bucket.file(path).delete().then(function () {
            console.log(`File deleted successfully in path: ${path}`)
        })
            .catch(function (error) {
                console.log(`File NOT deleted: ${path}`)
            });

    });

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
