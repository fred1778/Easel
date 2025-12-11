# Easel

 
 **Easel is a prototype cross-platform mobile application that provides a marketplace for artists and art consumers to buy and sell original art in an environment designed to be free of generative AI.**

I built Easel as my final project for my computer science MSc at the University of Bristol. I designed the platform based on research of the current relationship between generative AI and art and iterativley evaluated the design and feautures through user testing, including a final evaluation with a group of artists. 

The app comprises a backend comprising email/password authentication, NoSQL database for users and uploaded artwords, and cloud storage for artwork images. Firebase Google Cloud Functions are used to build an event-driven workflow which screens newly-uploaded images for generative AI using SightEngine API.

The front-end mobile application, developed for iOS and Android using Flutter, allows users to create accounts, favourite artwork, find art near their location via a map view, find local artists. Users can enhance their profile to become artist users able to upload work. 


<img width="300" height="672" alt="1000000141" src="https://github.com/user-attachments/assets/f4299abd-46f8-4f45-8ee0-805ed96e2dd1" />
<img width="300" height="672" alt="1000000143" src="https://github.com/user-attachments/assets/b45e4547-b59c-4b2d-a8d4-6bf874e561d7" />
<img width="300" height="672" alt="1000000138" src="https://github.com/user-attachments/assets/c2359aa5-9e14-4d13-a576-d18d3223ffeb" />
