package com.team.backend.service.model;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.team.backend.dto.UserPreference;
import org.springframework.stereotype.Component;
import javax.annotation.PostConstruct;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import com.fasterxml.jackson.databind.node.ObjectNode;

@Component
public class RouteModelRunner {

    private List<JsonNode> routes;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostConstruct
    public void loadRoutes() throws Exception {
        // /resources/model/routes.json 읽기
        InputStream is = getClass().getResourceAsStream("/model/routes.json");
        JsonNode root = objectMapper.readTree(is);

        routes = new ArrayList<>();
        root.get("routes").forEach(routes::add);
    }

    public JsonNode recommend(UserPreference pref) {

        // 1) 시간 기준 필터링
        List<JsonNode> eligible = routes.stream()
                .filter(r -> r.get("estimated_time_min").asInt() <= pref.getMaxTime())
                .toList();

        if (eligible.isEmpty()) return null;

        // 2) 점수 계산
        for (JsonNode r : eligible) {
            int score = switch (pref.getGoal()) {
                case "litter" -> r.get("trash_level").asInt();  // 쓰레기 많은 코스 추천
                case "calorie" -> (int)(r.get("distance_km").asDouble() * 100);  
                default -> 0;
            };
            ((ObjectNode) r).put("score", score);
        }

        // 3) 점수 기준으로 가장 높은 값 추천
        return eligible.stream()
                .max(Comparator.comparingInt(r -> r.get("score").asInt()))
                .orElse(null);
    }
}
