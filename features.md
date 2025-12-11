---
layout: default
title: Features
permalink: /features/
---

<h1 class="section-title">Feature showcase</h1>
<p class="section-subtitle">
  A quick tour of what Ploggify offers today and what we plan to build next.
</p>

<div class="card-grid">
  <div class="card">
    <div class="card-title">GPS-based plogging tracker</div>
    <p class="card-subtitle">
      Record your runs with distance, time, and route geometry. Each plogging
      session is stored in the backend and visualized in the mobile app.
    </p>
  </div>

  <div class="card">
    <div class="card-title">Trash-aware data model</div>
    <p class="card-subtitle">
      Each session keeps track of <strong>trashCount</strong>, estimated
      <strong>trashWeightKg</strong>, and <strong>trashDetails</strong> such as
      <em>Plastic</em>, <em>Metal</em>, and <em>Paper</em> counts.
    </p>
  </div>

  <div class="card">
    <div class="card-title">AI trash detection API</div>
    <p class="card-subtitle">
      A Python-based model is exposed via HTTP. The Java backend integrates
      with this service and exposes a clean API to the Flutter app.
    </p>
  </div>

  <div class="card">
    <div class="card-title">Route recommendation engine</div>
    <p class="card-subtitle">
      The backend keeps a database of routes with distance, elevation, curvature,
      and trash levels. Users can ask for a &ldquo;trash-heavy&rdquo; or
      &ldquo;clean&rdquo; route within a given time limit.
    </p>
  </div>

  <div class="card">
    <div class="card-title">Dashboard and leaderboard</div>
    <p class="card-subtitle">
      The dashboard ranks users by total distance and trash collected, and shows
      a weekly plogging summary to keep motivation high.
    </p>
  </div>

  <div class="card">
    <div class="card-title">Community feed</div>
    <p class="card-subtitle">
      Share plogging photos, like other posts, view dummy comments, and link
      each post to a specific plogging session.
    </p>
  </div>
</div>

<div class="section">
  <h2 class="section-title">More technical details</h2>
  <p class="section-subtitle">
    For API endpoints, configuration options, and the full architecture, see the
    technical documentation on ReadTheDocs.
  </p>
  <a class="btn-secondary" href="{{ site.project.docs_url }}" target="_blank">
    Open full documentation
  </a>
</div>
