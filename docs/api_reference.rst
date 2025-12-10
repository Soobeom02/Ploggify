API Reference
=============

Base URL
--------

.. code-block:: text

   http://localhost:8080

Endpoints
---------

API recommend
~~~~~~~~~~~~~~

The recommended plogging route information is returned based on the user's goal and maximum time conditions.

**Parameters**

* **goal**
    * ``litter`` : Trashy route recommendation (routes with more trash)
    * ``clean`` : Recommend a light walking route
* **maxTime**
    * Maximum user-entered time (in minutes)

**Response Fields**

* ``id``, ``name``, ``location``, ``distanceKm``, ``estimatedTimeMin``, ``trashMode``, ``trashLevel``

API trash-detect
~~~~~~~~~~~~~~~~~

When the list of image file names stored in the server is transmitted, the number of garbage detected in each image is returned.

.. note::
   Flutter sends strings such as "trash1.jpg" and "trash2.jpg" instead of local files for demonstration.

**Parameter**

* **images** : Comma-separated list of image filenames.

**Response Fields**

* ``imageFile``, ``totalTrashCount``, ``details``