Getting Started
==================

This guide explains how to run and test the Ploggify project in a local environment.

1. Prerequisites
----------------

The system requirements are as follows:

* **Frontend (Flutter):** Flutter SDK 3.22+, Dart 3.0+, VS Code
* **Backend (Spring Boot):** JDK 21, Spring Boot 4.0.0, Python 3.12

2. Clone the Repository
-----------------------

Clone the project repository and navigate to the directory.

.. code-block:: bash

   git clone https://github.com/Soobeom02/Ploggify.git
   cd ploggify-app

3. Install Flutter Dependencies
-------------------------------

Install the Flutter dependencies.

.. code-block:: bash

   flutter pub get

4. Run the Backend
------------------

Run the Spring Boot backend server.

.. code-block:: bash

   ./gradlew bootRun

5. Running the Flutter App
--------------------------

Run the Flutter app.

.. code-block:: bash

   flutter run

6. Testing Key Features
-----------------------

Here is how to test the key features of the app.

* **Start a Plogging Session**
    * Press **Start Plogging**
    * Allow location permission
    * The map should update in real time
    * The route polyline should appear as you move
* **Get Recommended Routes**
* **Trash Detection**
* **View Records**
    * All completed sessions appear in the **Records** tab.
* **Community Posting**
    * Choose a session
    * Add caption + image
    * Post appears with likes & comments

**API Test Examples:**

.. code-block::

   GET /api/recommend?goal=litter&maxTime=30
   GET /api/trash-detect?images=trash1.jpg,trash2.jpg