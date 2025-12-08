package com.hopecare.service;

import com.hopecare.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Authentication Service
 * Handles user login validation
 */
@Service
public class AuthService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Authenticate user by username and password
     * @return User object if valid, null if invalid
     */
    public User authenticate(String username, String password) {
        try {
            // Hash password to MD5
            String hashedPassword = hashPasswordMD5(password);
            
            System.out.println("🔍 AUTH DEBUG:");
            System.out.println("   Username: " + username);
            System.out.println("   Password: " + password);
            System.out.println("   Hashed: " + hashedPassword);
            
            // Query database (Oracle compatible)
            String sql = "SELECT u.user_id, u.username, u.full_name, u.email, " +
                        "r.role_id, r.role_name " +
                        "FROM tbl_users u " +
                        "JOIN tbl_roles r ON u.role_id = r.role_id " +
                        "WHERE u.username = ? AND u.password_hash = ?";
            
            User user = jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                User u = new User();
                u.setUserId(rs.getLong("user_id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setRoleId(rs.getLong("role_id"));
                u.setRoleName(rs.getString("role_name"));
                return u;
            }, username, hashedPassword);
            
            System.out.println("✅ Login SUCCESS: " + user.getFullName() + " (" + user.getRoleName() + ")");
            return user;
            
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            System.out.println("❌ Login FAILED: User not found or invalid credentials");
            return null;
        } catch (Exception e) {
            System.out.println("❌ Login FAILED: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Hash password using MD5
     * FIXED VERSION - Ensures correct MD5 hash generation
     */
    private String hashPasswordMD5(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(password.getBytes());
            BigInteger number = new BigInteger(1, messageDigest);
            String hashtext = number.toString(16);
            
            // Pad with leading zeros if needed
            while (hashtext.length() < 32) {
                hashtext = "0" + hashtext;
            }
            
            return hashtext;
            
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 algorithm not found", e);
        }
    }
}