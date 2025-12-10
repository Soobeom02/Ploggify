Technical Overview
==================

This document outlines the overall technical structure and key modules of the **Ploggify** service.

System Architecture
-------------------

The entire system consists of Frontend, Backend, and AI/ML modules.

- **Frontend:** Developed with Flutter (Dart), it provides a consistent user experience across various platforms.
- **Backend:** Built with Spring Boot (Java 21), it communicates with the frontend via REST API.
- **AI/ML Module:** Provides route recommendation based on user goals and detects and classifies trash objects in images using Python and YOLO (Roboflow).

Tech Stack Summary
------------------

.. list-table:: 
   :header-rows: 1
   :widths: 15 25 60

   * - Area
     - Tech
     - Description
   * - **Frontend**
     - Flutter
     - Cross-platform Mobile App (Dart)
   * - **Backend**
     - Java 21, Spring Boot
     - REST API Server, Process Orchestration
   * - **AI/ML**
     - Python, YOLO (Roboflow)
     - Route Recommendation, Object Detection & Classification
   * - **Database**
     - H2 Database
     - In-memory Relational Database

1. Frontend (Mobile Application)
--------------------------------

Responsible for user interaction.

* **Tech Stack:** Flutter (Dart), 'http' package
* **Key Features:**
    * **Camera Integration:** Taking and uploading trash photos during plogging.
    * **Interactive UI:** Displaying recommended routes on a map and visualizing workout results.
    * **API Communication:** Asynchronous communication with the backend server in JSON format.

.. list-table:: Frontend Technology Stack
   :widths: 15 25 60
   :header-rows: 1

   * - Category
     - Tech Name
     - Description
   * - **Framework**
     - Flutter (Dart)
     - Cross-platform mobile application development framework
   * - **UI/UX**
     - Material Design 3
     - Applies latest Android design guidelines and custom themes
   * - **API**
     - flutter_map
     - OpenStreetMap-based map rendering
   * - 
     - latlong2
     - Latitude/Longitude coordinate calculation and distance measurement algorithms
   * - 
     - geolocator
     - Real-time location permission management and coordinate stream reception
   * - **Network**
     - http
     - REST API communication with the Spring Boot backend server
   * - **Media**
     - file_picker
     - Access device gallery and select multiple images

2. Backend (Core Server)
------------------------

Acts as the backbone of the system, handling business logic and connections.

* **Tech Stack:** Java 21 (LTS), Spring Boot
* **Key Architecture:**
    * **Layered Architecture:** Layer separation of 'Controller' → 'Service' → 'Repository' → 'Database'.
    * **ProcessBuilder Integration:** Directly invokes the Python runtime using Java's `ProcessBuilder` API and exchanges data via standard I/O (StdOut).

.. list-table:: Backend Technology Stack
   :widths: 15 25 60
   :header-rows: 1

   * - Category
     - Tech Name
     - Description
   * - **Language**
     - Java 21
     - Latest LTS version supporting Virtual Threads
   * - **Framework**
     - Spring Boot
     - Building REST API servers and managing Dependency Injection (DI)
   * - **Database**
     - H2 Database
     - In-memory DB for ease of development and testing
   * - **Build Tool**
     - Gradle
     - Library dependency management and build automation
   * - **ORM**
     - Spring Data JPA
     - Mapping between Java objects and DB tables

3. Algorithm Module (Route Recommendation)
------------------------------------------

Algorithm engine proposing optimal routes tailored to user situation and purpose.

* **Tech Stack:** Python (Standard Library)
* **Key Features:**
    * **Constraint Filtering:** Selecting routes completable within user's available time (`max_time`).
    * **Goal-based Optimization:** Dynamic weight calculation based on user goals (`Litter` vs `Workout`).

.. list-table:: Algorithm Technology Stack
   :widths: 15 25 60
   :header-rows: 1

   * - Category
     - Tech Name
     - Description
   * - **Logic**
     - Weighted Scoring
     - Calculating weights for environmental score (trash density) and workout score (calories)
   * - **Data Handling**
     - JSON
     - Loading route datasets and formatting results
   * - **Interface**
     - Std I/O
     - Lightweight data input/output pipeline with the Java backend

4. AI Module (Trash Classification)
-----------------------------------

Module extracting trash information by visually analyzing uploaded images.

* **Tech Stack:** Python, YOLO(Roboflow)
* **Key Features:**
    * **Object Detection:** Identifying trash object locations within images via YOLO model.
    * **Auto Categorization:** Automatically mapping over 60 detailed items to 5 major categories (Metal, Plastic, Paper, Glass, Others).
    * **Filtering:** Applying Confidence-based filtering and NMS deduplication.

.. list-table:: AI Technology Stack
   :widths: 15 25 60
   :header-rows: 1

   * - Category
     - Tech Name
     - Description
   * - **Vision Model**
     - YOLO (via Roboflow)
     - Real-time object detection and image analysis API
   * - **Processing**
     - OpenCV
     - Image loading and preprocessing