package com.team.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api")
public class TrashModelController {

    @GetMapping("/trash-detect")
    public ResponseEntity<?> detectTrash(
            @RequestParam(required = false, name = "images") String images
    ) {
        try {
            String pythonExe = "C:\\Users\\pytho\\AppData\\Local\\Programs\\Python\\Python312\\python.exe";

            File workingDir = new File("C:\\Users\\pytho\\OneDrive\\바탕 화면\\trash");

            String scriptName = "trash_detect_v2.py";

            List<String> command = new ArrayList<>();
            command.add(pythonExe);
            command.add(scriptName);

            if (images != null && !images.isBlank()) {
                String[] split = images.split(",");
                command.addAll(Arrays.asList(split));
            }

            ProcessBuilder processBuilder = new ProcessBuilder(command);

            processBuilder.directory(workingDir);

            processBuilder.redirectErrorStream(true);

            Process process = processBuilder.start();

            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8)
            )) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line);
                }
            }

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                return ResponseEntity
                        .status(500)
                        .body("Python script failed. exitCode=" + exitCode + "\n" + output);
            }

            String json = output.toString();

            return ResponseEntity.ok(json);

        } catch (Exception e) {
            return ResponseEntity
                    .status(500)
                    .body("Error: " + e.getMessage());
        }
    }
}
