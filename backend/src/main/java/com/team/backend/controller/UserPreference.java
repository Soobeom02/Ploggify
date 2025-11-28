package com.team.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserPreference {

    // "litter" 또는 "calorie"
    private String goal;

    // 추천 가능한 최대 시간 (분)
    private int maxTime;
}
