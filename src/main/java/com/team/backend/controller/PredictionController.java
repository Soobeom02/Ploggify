package com.team.backend.controller;

import com.team.backend.dto.TrashData;
import com.team.backend.service.TrashService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class PredictionController {
    private final TrashService service;

    public PredictionController(TrashService service) {
        this.service = service;
    }

    @PostMapping("/trash")
    public ResponseEntity<TrashData> receiveAndEcho(@RequestBody TrashData data) {
        TrashData result = service.echoData(data);
        return ResponseEntity.ok(result);
    }
}
