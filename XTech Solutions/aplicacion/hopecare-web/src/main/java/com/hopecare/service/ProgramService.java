package com.hopecare.service;

import com.hopecare.model.Program;
import com.hopecare.repository.DatabaseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Program Service
 * Business logic for social program management
 */
@Service
public class ProgramService {

    @Autowired
    private DatabaseRepository repository;

    /**
     * Get all active programs
     */
    public List<Program> getAllPrograms() {
        return repository.getAllPrograms();
    }

    /**
     * Get program by ID
     */
    public Program getProgramById(Long id) {
        return repository.getProgramById(id);
    }

    /**
     * Create new program
     */
    public Long createProgram(Program program) {
        validateProgram(program);
        return repository.createProgram(program);
    }

    /**
     * Get inventory status
     */
    public List<Map<String, Object>> getInventoryStatus() {
        return repository.getInventoryStatus();
    }

    /**
     * Validate program data
     */
    private void validateProgram(Program program) {
        if (program.getProgramName() == null || program.getProgramName().trim().isEmpty()) {
            throw new IllegalArgumentException("Program name is required");
        }
        if (program.getEndDate() != null && program.getStartDate() != null) {
            if (program.getEndDate().isBefore(program.getStartDate())) {
                throw new IllegalArgumentException("End date cannot be before start date");
            }
        }
    }
}