package com.team.backend.service;

import com.team.backend.domain.Route;
import com.team.backend.domain.RouteCoord;
import com.team.backend.domain.TrashPoint;
import com.team.backend.dto.RouteRequest;
import com.team.backend.repository.RouteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class RouteService {
    private final RouteRepository routeRepository;

    public RouteService(RouteRepository routeRepository) {
        this.routeRepository = routeRepository;
    }

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
            coord.setRoute(route);   // FK 설정
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
            tp.setRoute(route);      // FK 설정
            trashEntities.add(tp);
        }
        route.setTrashPoints(trashEntities);

        return routeRepository.save(route);
    }
}
