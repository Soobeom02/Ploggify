Maintenance and Troubleshooting
===============================

This section covers common issues that occur during development and testing, along with their solutions.

API recommend call failed (404 or 500)
---------------------------------------

* **Cause**
    * Backend server not running
    * JSON field name mismatch
    * Query parameter missing
* **Solution**
    * Check API URL, Backend Run Log, Print Response of the Flutter Console

Image analysis request failed
-----------------------------

* **Symptom**
    * Response list length 0
* **Cause**
    * Image file name and physical file do not match at the backend
    * FilePicker does not yet have the structure to transfer the actual local file selected
    * Backend encountered CORS or server path issues
* **Solution**
    * Check ``/api/trash-detect?images=trash1.jpg``
    * Verifying the static image path of the server
    * Add logs to see if files load normally from the server console

Polyline not visible on the map
-------------------------------

* **Cause**
    * ``_path`` list is empty
    * GPS stream is not updating
    * Timer is not running
* **Solution**
    * Check if ``_startRun()`` is actually being called (add debug logs)
    * Check ``flutter_map`` version compatibility
    * Test on a real device while physically moving (simulator does not update GPS)

Session data not updated in the Records tab
-------------------------------------------

* **Cause**
    * ``onSessionCompleted`` callback not triggered
    * Parent widget does not update ``_sessions`` list in the UI
* **Solution**
    * Check the structure in ``main.dart``:

.. code-block:: dart

   // 1) StartScreen setup
   StartScreen(
     onSessionCompleted: _addSession,
   );

   // 2) Add session properly:
   void _addSession(PlogSession s) {
     setState(() {
       _sessions.insert(0, s);
     });
   }

Flutter Hot Reload issues
-------------------------

**Symptom**

1. UI does not update
2. App crashes after modifying model fields

**Solution**

1. Perform a **Hot Restart** instead of Hot Reload
2. Restart the app especially after modifying files under ``models/*.dart``