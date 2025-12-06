package com.team.backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class RouteRequest {

    private String name;
    private String location;
    private double distanceKm;
    private double elevationGain;
    private double curvature;
    private int estimatedTimeMin;
    private int estimatedCalories;

    private List<CoordDto> coords;
    private List<TrashPointDto> trashPoints;

    // 내부 DTO
    @Getter
    @Setter
    public static class CoordDto {
        private double lat;
        private double lng;
    }

    @Getter
    @Setter
    public static class TrashPointDto {
        private double lat;
        private double lng;
        private int level;
    }
}
