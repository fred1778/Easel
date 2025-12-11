# Easel

 
 **Easel is a prototype cross-platform mobile application that provides a marketplace for artists and art consumers to buy and sell original art in an environment designed to be free of generative AI.**

I built Easel as my final project for my computer science MSc at the University of Bristol. I designed the platform based on research of the current relationship between generative AI and art and iterativley evaluated the design and feautures through user testing, including a final evaluation with a group of artists. 

The app comprises a backend comprising email/password authentication, NoSQL database for users and uploaded artwords, and cloud storage for artwork images. Firebase Google Cloud Functions are used to build an event-driven workflow which screens newly-uploaded images for generative AI using SightEngine API.

The front-end mobile application, developed for iOS and Android using Flutter, allows users to create accounts, favourite artwork, find art near their location via a map view, find local artists. Users can enhance their profile to become artist users able to upload work. 


