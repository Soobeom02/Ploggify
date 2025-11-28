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
//신규 기능: UserPreference 입력(목표,목표시간)을 받아 추천 경로 생성 + DB 저장

@PostMapping("/recommend")
public ResponseEntity<?> recommend(@RequestBody UserPreference pref) {

    Route result = routeService.recommendAndSave(pref);

    if (result == null) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("조건에 맞는 추천 경로가 없습니다.");
    }

    return ResponseEntity.ok(result);
}
