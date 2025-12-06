package com.team.backend.service.model;

import org.springframework.stereotype.Component;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

import java.io.InputStream;
import java.io.InputStreamReader;

@Component
public class RouteModelRunner {

    public JSONArray getRecommendedRoutes() {
        JSONArray routes = new JSONArray();
        try {
            JSONParser parser = new JSONParser();
            InputStream is = getClass().getClassLoader().getResourceAsStream("python/routes.json");

            if (is != null) {
                JSONObject root = (JSONObject) parser.parse(new InputStreamReader(is));
                routes = (JSONArray) root.get("routes");  // ← 핵심 수정 부분
            } else {
                System.err.println("❌ routes.json 파일을 classpath에서 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            System.err.println("❌ JSON 파싱 중 오류 발생:");
            e.printStackTrace();
        }
        return routes;
    }
}
