/**
 * Import function triggers from their respective submodules:
 **/

const { onObjectFinalized } = require("firebase-functions/v2/storage"); // new upload
const { initializeApp } = require("firebase-admin/app");
const { getStorage } = require("firebase-admin/storage");
const logger = require("firebase-functions/logger");
const path = require("path");

const axios = require("axios");
const FormData = require("form-data");
const fs = require("fs");
data.append("media", fs.createReadStream("/full/path/to/image.jpg"));
data.append("models", "type,text,genai");
data.append("api_user", "620259281");
data.append("api_secret", "xBjw7YPmAM63MVPZJFaMydCQDRZL8Ho3");
initializeApp();

//Images bucket = easel-e5104.firebasestorage.app, location USCENTRAL1
// Set location to align with location of cloud storage. For some reason the database is in eur3, there would have been a reason why FB recommended or enforced using US for cloud...
// Docs say that Function may be in any location if the trigger region is set to us-central1 so could set to eur3 to match firestore but we'll see

exports.checkImage = onObjectFinalized(
  {
    region: "us-central1",
    bucket: "easel-e5104.firebasestorage.app",
  },
  (event) => {
    data = new FormData();

    axios({
      method: "post",
      url: "https://api.sightengine.com/1.0/check.json",
      data: data,
      headers: data.getHeaders(),
    })
      .then(function (response) {
        // on success: handle response
        console.log(response.data);
      })
      .catch(function (error) {
        // handle error
        if (error.response) console.log(error.response.data);
        else console.log(error.message);
      });

    console.log("item uploaded");
  }
);
