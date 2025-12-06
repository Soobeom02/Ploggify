package com.team.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.*;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api")
public class ModelController {

    @GetMapping(value = "/recommend", produces = "application/json; charset=UTF-8")
    public ResponseEntity<?> recommendRoute(
            @RequestParam String goal,
            @RequestParam int maxTime
    ) {
        try {
            ProcessBuilder pb = new ProcessBuilder(
                    "python",
                    "recommend.py",
                    goal,
                    String.valueOf(maxTime)
            );

            // 파이썬 파일 경로
            pb.directory(new File("src/main/resources/python"));
            pb.redirectErrorStream(true);

            Process process = pb.start();

            // ★★★ 핵심 부분 — 반드시 UTF-8 로 읽어야 함 ★★★
            BufferedReader reader =
                    new BufferedReader(
                            new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8)
                    );

            StringBuilder output = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                output.append(line);
            }

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                return ResponseEntity.status(500).body("Python script failed.");
            }

            // JSON 그대로 반환
            return ResponseEntity
                    .ok()
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .body(output.toString());

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}
