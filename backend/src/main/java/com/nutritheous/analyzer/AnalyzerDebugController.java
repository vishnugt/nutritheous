package com.nutritheous.analyzer;

import com.nutritheous.common.dto.AnalysisResponse;
import com.nutritheous.storage.GoogleCloudStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
public class AnalyzerDebugController {

    @Autowired
    private AnalyzerService analyzerService;

    @Autowired
    private GoogleCloudStorageService storageService;

    @PostMapping("/test-analyzer")
    public ResponseEntity<AnalysisResponse> testAnalyzer(
            @RequestParam String imageUrl,
            @RequestParam(required = false) String description) {
        try {
            AnalysisResponse response = analyzerService.analyzeImage(imageUrl, description);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            throw new RuntimeException("Analyzer test failed: " + e.getMessage(), e);
        }
    }

    @GetMapping("/test-storage")
    public ResponseEntity<Map<String, String>> testStorage(@RequestParam String objectName) {
        try {
            Map<String, String> result = new HashMap<>();

            // Test presigned URL generation
            String presignedUrl = storageService.getPresignedUrl(objectName);
            result.put("presignedUrl", presignedUrl);
            result.put("status", "success");
            result.put("message", "GCS connection successful");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, String> result = new HashMap<>();
            result.put("status", "error");
            result.put("message", e.getMessage());
            return ResponseEntity.status(500).body(result);
        }
    }
}
