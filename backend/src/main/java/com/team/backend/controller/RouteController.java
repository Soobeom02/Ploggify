package com.team.backend.controller;

import com.team.backend.domain.Route;
import com.team.backend.dto.RouteRequest;
import com.team.backend.service.RouteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/routes")
public class RouteController {

    private final RouteService routeService;

    public RouteController(RouteService routeService) {
        this.routeService = routeService;
    }

    @PostMapping
    public ResponseEntity<Long> createRoute(@RequestBody RouteRequest request) {
        Route saved = routeService.saveRoute(request);
        return ResponseEntity.ok(saved.getId());  // 저장된 route_id 반환
    }
}
