Configuration Guide
===================

This document outlines the development environment and permission settings required to run the project.

Development Environment
-----------------------

* **Flutter:** 3.22
* **Spring Boot:** 4.0.0

API Server Settings
-------------------

* **Base URL:** ``http://localhost:8080``

Set the Image Select (FilePicker)
---------------------------------

Platform-specific permissions are required to use the image selection feature.

* **Android:** Storage permission
* **iOS:** Photo library permission

Setting Location Permissions
----------------------------

Location permission settings are required to track plogging routes.

Android
~~~~~~~

Add the following permissions to the ``AndroidManifest.xml`` file.

.. code-block:: xml

   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

iOS
~~~

Add the following keys and descriptions to the ``Info.plist`` file.

.. code-block:: xml

   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to track plogging routes.</string>