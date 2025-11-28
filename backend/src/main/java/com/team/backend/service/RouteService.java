package com.team.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.team.backend.domain.Route;
import com.team.backend.domain.RouteCoord;
import com.team.backend.domain.TrashPoint;
import com.team.backend.dto.RouteRequest;
import com.team.backend.dto.UserPreference;
import com.team.backend.repository.RouteRepository;
import com.team.backend.service.model.RouteModelRunner;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class RouteService {

    private final RouteRepository routeRepository;
    private final RouteModelRunner modelRunner;

    public RouteService(RouteRepository routeRepository,
                        RouteModelRunner modelRunner) {
        this.routeRepository = routeRepository;
        this.modelRunner = modelRunner;
    }

    /**
     * 기존 기능: 클라이언트가 직접 보내는 코스를 DB에 저장
     */
    @Transactional
    public Route saveRoute(RouteRequest request) {
        Route route = new Route();
        route.setName(request.getName());
        route.setLocation(request.getLocation());
        route.setDistanceKm(request.getDistanceKm());
        route.setElevationGain(request.getElevationGain());
        route.setCurvature(request.getCurvature());
        route.setEstimatedTimeMin(request.getEstimatedTimeMin());
        route.setEstimatedCalories(request.getEstimatedCalories());

        // coords
        List<RouteCoord> coordEntities = new ArrayList<>();
        int seq = 0;
        for (RouteRequest.CoordDto dto : request.getCoords()) {
            RouteCoord coord = new RouteCoord();
            coord.setSeq(seq++);
            coord.setLat(dto.getLat());
            coord.setLng(dto.getLng());
            coord.setRoute(route);
            coordEntities.add(coord);
        }
        route.setCoords(coordEntities);

        // trashPoints
        List<TrashPoint> trashEntities = new ArrayList<>();
        for (RouteRequest.TrashPointDto dto : request.getTrashPoints()) {
            TrashPoint tp = new TrashPoint();
            tp.setLat(dto.getLat());
            tp.setLng(dto.getLng());
            tp.setLevel(dto.getLevel());
            tp.setRoute(route);
            trashEntities.add(tp);
        }
        route.setTrashPoints(trashEntities);

        return routeRepository.save(route);
    }


    /**
     * 신규 기능:
     * Flutter 앱에서 "추천 요청(goal, maxTime)"을 보내면
     * RouteModelRunner(추천 알고리즘)를 실행하고
     * 추천된 코스를 Route 엔티티로 매핑 후 DB에 저장
     */
    @Transactional
    public Route recommendAndSave(UserPreference pref) {

        // 1) 추천 모델 실행
        JsonNode result = modelRunner.recommend(pref);
        if (result == null) return null;

        // 2) 추천된 JsonNode → Route 엔티티 변환
        Route route = new Route();
        route.setName(result.get("name").asText());
        route.setLocation(result.get("location").asText());
        route.setDistanceKm(result.get("distance_km").asDouble());
        route.setEstimatedTimeMin(result.get("estimated_time_min").asInt());

        // Flutter 앱과 동일 구조
        route.setTrashMode(result.get("trash_mode").asText());
        route.setTrashLevel(result.get("trash_level").asInt());

        // coords/trashPoints는 사용하지 않으므로 빈 리스트로 설정
        route.setCoords(new ArrayList<>());
        route.setTrashPoints(new ArrayList<>());

        // 3) DB 저장 후 반환
        return routeRepository.save(route);
    }
}
