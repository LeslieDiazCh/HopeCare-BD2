package com.hopecare.controller;

import com.hopecare.model.Program;
import com.hopecare.service.ProgramService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Program Controller
 * Handles social program management operations
 */
@Controller
@RequestMapping("/programs")
public class ProgramController {

    @Autowired
    private ProgramService programService;

    /**
     * Show programs page
     */
    @GetMapping
    public String programsPage(Model model) {
        try {
            List<Program> programs = programService.getAllPrograms();
            model.addAttribute("programs", programs);
        } catch (Exception e) {
            model.addAttribute("error", "Error loading programs: " + e.getMessage());
        }
        return "programs";
    }

    /**
     * Get all programs (AJAX)
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<?> getAllPrograms() {
        try {
            List<Program> programs = programService.getAllPrograms();
            return ResponseEntity.ok(programs);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Get program by ID (AJAX)
     */
    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<?> getProgramById(@PathVariable Long id) {
        try {
            Program program = programService.getProgramById(id);
            if (program == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(createErrorResponse("Program not found"));
            }
            return ResponseEntity.ok(program);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Create new program (AJAX)
     */
    @PostMapping("/api/create")
    @ResponseBody
    public ResponseEntity<?> createProgram(@RequestBody Program program) {
        try {
            Long programId = programService.createProgram(program);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Program created successfully");
            response.put("programId", programId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error creating program: " + e.getMessage()));
        }
    }

    /**
     * Get inventory status (AJAX)
     */
    @GetMapping("/api/inventory")
    @ResponseBody
    public ResponseEntity<?> getInventoryStatus() {
        try {
            List<Map<String, Object>> inventory = programService.getInventoryStatus();
            return ResponseEntity.ok(inventory);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Helper method to create error response
     */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("message", message);
        return error;
    }
}