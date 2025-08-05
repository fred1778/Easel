
import io
import pathlib
from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore

from firebase_functions import storage_fn
from firebase_functions import core
from firebase_functions import firestore_fn
import google.cloud.firestore

#from PIL import Image

import requests
import json

set_global_options(max_instances=10)

initialize_app()
from firebase_admin import storage


@storage_fn.on_object_finalized(region="us-central1")
def imgCheck(event: storage_fn.CloudEvent[storage_fn.StorageObjectData]) -> None:
 
 #this is the bucket name of the default bucket (because we didn't specify which bucket and we only have one anwyay)
 bucket_id = event.data.bucket 
 #generate a path from the newly uploaded image name. pathlib means we don't need to worry about the rest of the local path in the CF env
 img_path = pathlib.PurePath(event.data.name)
 #we also want to check the new upload is an image by checking its MIME type
 img_type = event.data.content_type
 print("valid img")
 storageBucket = storage.bucket(bucket_id)
 img_blob = storageBucket.blob(str(img_path))
 img_bytes = img_blob.download_as_bytes()
 #img_binary = Image.open(io.BytesIO(img_bytes))
 
 print()
 params = {
   'models': 'genai',
   'api_user': '620259281',
   'api_secret': 'xBjw7YPmAM63MVPZJFaMydCQDRZL8Ho3'
 }
 r = requests.post('https://api.sightengine.com/1.0/check.json', files={"media" : img_bytes}, data=params)
 report = json.loads(r.text)
 #if result 80%< reject, if 60< refer, if >60 auto accept
 score = report["type"]["ai_generated"]
 print(score)
 status = "rejected"
 if score >= 0.6 :
  print("possible AI, reject")
  storageBucket.delete_blob(img_blob.name)
  
 else:
  docpath = "artworks/" + event.data.name.replace("images/", "")
  print(docpath)
  if(score >= 0.3):
   #refer?
   print("provisional pass")
   status = "referred"
  else:
   print("full pass")
   status = "approved"

#do outcome updates 
 firestore_client: google.cloud.firestore.Client = firestore.client()
 firestore_client.document(docpath).update({"status" : status})


  