package com.team.backend.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "routes")
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;   // route_id 역할

    private String name;
    private String location;

    @Column(name = "distance_km")
    private double distanceKm;

    @Column(name = "elevation_gain")
    private double elevationGain;

    private double curvature;

    @Column(name = "estimated_time_min")
    private int estimatedTimeMin;

    @Column(name = "estimated_calories")
    private int estimatedCalories;

    // 코스 좌표들
    @OneToMany(mappedBy = "route", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RouteCoord> coords;

    // 쓰레기 포인트
    @OneToMany(mappedBy = "route", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TrashPoint> trashPoints;
}
