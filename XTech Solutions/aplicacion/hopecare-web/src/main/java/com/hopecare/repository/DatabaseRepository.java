package com.hopecare.repository;

import com.hopecare.model.*;
import oracle.jdbc.OracleTypes;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.Map;

/**
 * Database Repository
 * Handles all database operations using JDBC and PL/SQL packages
 */
@Repository
public class DatabaseRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // ================================================================
    // DONOR OPERATIONS
    // ================================================================

    /**
     * Get all donors from view
     */
    public List<Donor> getAllDonors() {
        String sql = "SELECT donor_id, donor_code, full_name, email, phone, donor_type, " +
                    "address, is_active, created_at, total_donations, total_value_pen, " +
                    "last_donation_date FROM vw_donor_summary WHERE is_active = 'Y' " +
                    "ORDER BY full_name";
        return jdbcTemplate.query(sql, new DonorRowMapper());
    }

    /**
     * Get donor by ID
     */
    public Donor getDonorById(Long donorId) {
        String sql = "SELECT donor_id, donor_code, full_name, email, phone, donor_type, " +
                    "address, is_active, created_at, total_donations, total_value_pen, " +
                    "last_donation_date FROM vw_donor_summary WHERE donor_id = ?";
        List<Donor> donors = jdbcTemplate.query(sql, new DonorRowMapper(), donorId);
        return donors.isEmpty() ? null : donors.get(0);
    }

    /**
     * Register new donor using PL/SQL package
     */
    public Long registerDonor(Donor donor) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_DONORS")
                .withProcedureName("REGISTER_DONOR")
                .declareParameters(
                        new SqlParameter("p_full_name", Types.VARCHAR),
                        new SqlParameter("p_email", Types.VARCHAR),
                        new SqlParameter("p_phone", Types.VARCHAR),
                        new SqlParameter("p_donor_type", Types.VARCHAR),
                        new SqlParameter("p_address", Types.VARCHAR),
                        new SqlOutParameter("p_donor_id", Types.NUMERIC)
                );

        Map<String, Object> result = jdbcCall.execute(
                donor.getFullName(),
                donor.getEmail(),
                donor.getPhone(),
                donor.getDonorType(),
                donor.getAddress()
        );

        return ((Number) result.get("p_donor_id")).longValue();
    }

    /**
     * Update donor using PL/SQL package
     */
    public void updateDonor(Donor donor) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_DONORS")
                .withProcedureName("UPDATE_DONOR")
                .declareParameters(
                        new SqlParameter("p_donor_id", Types.NUMERIC),
                        new SqlParameter("p_full_name", Types.VARCHAR),
                        new SqlParameter("p_email", Types.VARCHAR),
                        new SqlParameter("p_phone", Types.VARCHAR),
                        new SqlParameter("p_address", Types.VARCHAR)
                );

        jdbcCall.execute(
                donor.getDonorId(),
                donor.getFullName(),
                donor.getEmail(),
                donor.getPhone(),
                donor.getAddress()
        );
    }

    /**
     * Search donors
     */
    public List<Donor> searchDonors(String searchTerm) {
        String sql = "SELECT donor_id, donor_code, full_name, email, phone, donor_type, " +
                    "address, is_active, created_at, total_donations, total_value_pen, " +
                    "last_donation_date FROM vw_donor_summary WHERE is_active = 'Y' " +
                    "AND (UPPER(full_name) LIKE ? OR UPPER(donor_code) LIKE ? OR UPPER(email) LIKE ?) " +
                    "ORDER BY full_name";
        String search = "%" + searchTerm.toUpperCase() + "%";
        return jdbcTemplate.query(sql, new DonorRowMapper(), search, search, search);
    }

    // ================================================================
    // BENEFICIARY OPERATIONS
    // ================================================================

    /**
     * Get all beneficiaries from view
     */
    public List<Beneficiary> getAllBeneficiaries() {
        String sql = "SELECT beneficiary_id, beneficiary_code, full_name, family_size, " +
                    "phone, address, district, city, is_active, created_at, total_deliveries, " +
                    "total_quantity_received, total_value_received_pen, last_delivery_date " +
                    "FROM vw_beneficiary_summary WHERE is_active = 'Y' ORDER BY full_name";
        return jdbcTemplate.query(sql, new BeneficiaryRowMapper());
    }

    /**
     * Get beneficiary by ID
     */
    public Beneficiary getBeneficiaryById(Long beneficiaryId) {
        String sql = "SELECT beneficiary_id, beneficiary_code, full_name, family_size, " +
                    "phone, address, district, city, is_active, created_at, total_deliveries, " +
                    "total_quantity_received, total_value_received_pen, last_delivery_date " +
                    "FROM vw_beneficiary_summary WHERE beneficiary_id = ?";
        List<Beneficiary> beneficiaries = jdbcTemplate.query(sql, new BeneficiaryRowMapper(), beneficiaryId);
        return beneficiaries.isEmpty() ? null : beneficiaries.get(0);
    }

    /**
     * Register new beneficiary using PL/SQL package
     */
    public Long registerBeneficiary(Beneficiary beneficiary) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_BENEFICIARIES")
                .withProcedureName("REGISTER_BENEFICIARY")
                .declareParameters(
                        new SqlParameter("p_full_name", Types.VARCHAR),
                        new SqlParameter("p_family_size", Types.NUMERIC),
                        new SqlParameter("p_phone", Types.VARCHAR),
                        new SqlParameter("p_address", Types.VARCHAR),
                        new SqlParameter("p_district", Types.VARCHAR),
                        new SqlParameter("p_city", Types.VARCHAR),
                        new SqlParameter("p_notes", Types.VARCHAR),
                        new SqlOutParameter("p_beneficiary_id", Types.NUMERIC)
                );

        Map<String, Object> result = jdbcCall.execute(
                beneficiary.getFullName(),
                beneficiary.getFamilySize(),
                beneficiary.getPhone(),
                beneficiary.getAddress(),
                beneficiary.getDistrict(),
                beneficiary.getCity(),
                beneficiary.getNotes()
        );

        return ((Number) result.get("p_beneficiary_id")).longValue();
    }

    /**
     * Update beneficiary using PL/SQL package
     */
    public void updateBeneficiary(Beneficiary beneficiary) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_BENEFICIARIES")
                .withProcedureName("UPDATE_BENEFICIARY")
                .declareParameters(
                        new SqlParameter("p_beneficiary_id", Types.NUMERIC),
                        new SqlParameter("p_full_name", Types.VARCHAR),
                        new SqlParameter("p_family_size", Types.NUMERIC),
                        new SqlParameter("p_phone", Types.VARCHAR),
                        new SqlParameter("p_address", Types.VARCHAR),
                        new SqlParameter("p_district", Types.VARCHAR),
                        new SqlParameter("p_city", Types.VARCHAR),
                        new SqlParameter("p_notes", Types.VARCHAR)
                );

        jdbcCall.execute(
                beneficiary.getBeneficiaryId(),
                beneficiary.getFullName(),
                beneficiary.getFamilySize(),
                beneficiary.getPhone(),
                beneficiary.getAddress(),
                beneficiary.getDistrict(),
                beneficiary.getCity(),
                beneficiary.getNotes()
        );
    }

    // ================================================================
    // PROGRAM OPERATIONS
    // ================================================================

    /**
     * Get all programs from view
     */
    public List<Program> getAllPrograms() {
        String sql = "SELECT program_id, program_code, program_name, description, program_type, " +
                    "start_date, end_date, is_active, created_at, total_donations_received, " +
                    "total_donation_value_pen, total_deliveries_made, total_delivery_value_pen, " +
                    "unique_beneficiaries_served, inventory_items " +
                    "FROM vw_program_summary WHERE is_active = 'Y' ORDER BY program_code";
        return jdbcTemplate.query(sql, new ProgramRowMapper());
    }

    /**
     * Get program by ID
     */
    public Program getProgramById(Long programId) {
        String sql = "SELECT program_id, program_code, program_name, description, program_type, " +
                    "start_date, end_date, is_active, created_at, total_donations_received, " +
                    "total_donation_value_pen, total_deliveries_made, total_delivery_value_pen, " +
                    "unique_beneficiaries_served, inventory_items " +
                    "FROM vw_program_summary WHERE program_id = ?";
        List<Program> programs = jdbcTemplate.query(sql, new ProgramRowMapper(), programId);
        return programs.isEmpty() ? null : programs.get(0);
    }

    /**
     * Create new program using PL/SQL package
     */
    public Long createProgram(Program program) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_PROGRAMS")
                .withProcedureName("CREATE_PROGRAM")
                .declareParameters(
                        new SqlParameter("p_program_name", Types.VARCHAR),
                        new SqlParameter("p_description", Types.VARCHAR),
                        new SqlParameter("p_program_type", Types.VARCHAR),
                        new SqlParameter("p_start_date", Types.DATE),
                        new SqlParameter("p_end_date", Types.DATE),
                        new SqlOutParameter("p_program_id", Types.NUMERIC)
                );

        Map<String, Object> result = jdbcCall.execute(
                program.getProgramName(),
                program.getDescription(),
                program.getProgramType(),
                program.getStartDate(),
                program.getEndDate()
        );

        return ((Number) result.get("p_program_id")).longValue();
    }

    // ================================================================
    // DONATION OPERATIONS
    // ================================================================

    /**
     * Get all donations from view
     */
    public List<Donation> getAllDonations() {
        String sql = "SELECT donation_id, donation_code, donation_date, donor_code, donor_name, " +
                    "donor_type, donation_type_name, original_amount, currency_code, currency_symbol, " +
                    "amount_in_pen, product_description, quantity, unit_value, program_code, " +
                    "program_name, notes, created_by_name, created_at " +
                    "FROM vw_donation_details ORDER BY donation_date DESC";
        return jdbcTemplate.query(sql, new DonationRowMapper());
    }

    /**
     * Get currencies for dropdown
     */
    public List<Map<String, Object>> getCurrencies() {
        String sql = "SELECT currency_id, currency_code, currency_name, symbol " +
                    "FROM tbl_currencies WHERE is_active = 'Y' ORDER BY currency_code";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Register money donation using PL/SQL package
     */
    public Long registerMoneyDonation(Long donorId, Double amount, Long currencyId, 
                                      Long programId, String notes, Long createdBy) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_DONATIONS")
                .withProcedureName("REGISTER_MONEY_DONATION")
                .declareParameters(
                        new SqlParameter("p_donor_id", Types.NUMERIC),
                        new SqlParameter("p_amount", Types.NUMERIC),
                        new SqlParameter("p_currency_id", Types.NUMERIC),
                        new SqlParameter("p_program_id", Types.NUMERIC),
                        new SqlParameter("p_notes", Types.VARCHAR),
                        new SqlParameter("p_created_by", Types.NUMERIC),
                        new SqlOutParameter("p_donation_id", Types.NUMERIC)
                );

        Map<String, Object> result = jdbcCall.execute(
                donorId, amount, currencyId, programId, notes, createdBy
        );

        return ((Number) result.get("p_donation_id")).longValue();
    }

    /**
     * Register product donation using PL/SQL package
     */
    public Long registerProductDonation(Long donorId, String productDescription, 
                                        Integer quantity, Double unitValue, Long programId, 
                                        String notes, Long createdBy) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_DONATIONS")
                .withProcedureName("REGISTER_PRODUCT_DONATION")
                .declareParameters(
                        new SqlParameter("p_donor_id", Types.NUMERIC),
                        new SqlParameter("p_product_description", Types.VARCHAR),
                        new SqlParameter("p_quantity", Types.NUMERIC),
                        new SqlParameter("p_unit_value", Types.NUMERIC),
                        new SqlParameter("p_program_id", Types.NUMERIC),
                        new SqlParameter("p_notes", Types.VARCHAR),
                        new SqlParameter("p_created_by", Types.NUMERIC),
                        new SqlOutParameter("p_donation_id", Types.NUMERIC)
                );

        Map<String, Object> result = jdbcCall.execute(
                donorId, productDescription, quantity, unitValue, programId, notes, createdBy
        );

        return ((Number) result.get("p_donation_id")).longValue();
    }

    // ================================================================
    // DELIVERY OPERATIONS
    // ================================================================

    /**
     * Get all deliveries from view
     */
    public List<Delivery> getAllDeliveries() {
        String sql = "SELECT delivery_id, delivery_code, delivery_date, status, " +
                    "beneficiary_code, beneficiary_name, family_size, district, city, " +
                    "program_code, program_name, program_type, product_description, " +
                    "quantity_delivered, unit_value, total_value, notes, " +
                    "created_by_name, approved_by_name, created_at " +
                    "FROM vw_delivery_details ORDER BY delivery_date DESC";
        return jdbcTemplate.query(sql, new DeliveryRowMapper());
    }

    /**
     * Get inventory status
     */
    public List<Map<String, Object>> getInventoryStatus() {
        String sql = "SELECT program_code, program_name, product_description, " +
                    "available_quantity, reserved_quantity, delivered_quantity, " +
                    "unit_value, available_value, stock_status, last_updated " +
                    "FROM vw_inventory_status ORDER BY program_code, product_description";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Perform delivery using PL/SQL package
     */
    public Long performDelivery(Long beneficiaryId, Long programId, String productDescription,
                               Integer quantity, String notes, Long createdBy) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_DELIVERIES")
                .withProcedureName("PERFORM_DELIVERY")
                .declareParameters(
                        new SqlParameter("p_beneficiary_id", Types.NUMERIC),
                        new SqlParameter("p_program_id", Types.NUMERIC),
                        new SqlParameter("p_product_description", Types.VARCHAR),
                        new SqlParameter("p_quantity", Types.NUMERIC),
                        new SqlParameter("p_notes", Types.VARCHAR),
                        new SqlParameter("p_created_by", Types.NUMERIC),
                        new SqlOutParameter("p_delivery_id", Types.NUMERIC)
                );

        Map<String, Object> result = jdbcCall.execute(
                beneficiaryId, programId, productDescription, quantity, notes, createdBy
        );

        return ((Number) result.get("p_delivery_id")).longValue();
    }

    // ================================================================
    // DASHBOARD METRICS
    // ================================================================

    /**
     * Get dashboard metrics
     */
    public Map<String, Object> getDashboardMetrics() {
        String sql = "SELECT * FROM vw_dashboard_metrics";
        return jdbcTemplate.queryForMap(sql);
    }

    // ================================================================
    // ROW MAPPERS
    // ================================================================

    private static class DonorRowMapper implements RowMapper<Donor> {
        @Override
        public Donor mapRow(ResultSet rs, int rowNum) throws SQLException {
            Donor donor = new Donor();
            donor.setDonorId(rs.getLong("donor_id"));
            donor.setDonorCode(rs.getString("donor_code"));
            donor.setFullName(rs.getString("full_name"));
            donor.setEmail(rs.getString("email"));
            donor.setPhone(rs.getString("phone"));
            donor.setDonorType(rs.getString("donor_type"));
            donor.setAddress(rs.getString("address"));
            donor.setIsActive(rs.getString("is_active"));
            donor.setCreatedAt(rs.getTimestamp("created_at") != null ? 
                rs.getTimestamp("created_at").toLocalDateTime() : null);
            donor.setTotalDonations(rs.getInt("total_donations"));
            donor.setTotalValuePen(rs.getDouble("total_value_pen"));
            donor.setLastDonationDate(rs.getTimestamp("last_donation_date") != null ? 
                rs.getTimestamp("last_donation_date").toLocalDateTime() : null);
            return donor;
        }
    }

    private static class BeneficiaryRowMapper implements RowMapper<Beneficiary> {
        @Override
        public Beneficiary mapRow(ResultSet rs, int rowNum) throws SQLException {
            Beneficiary beneficiary = new Beneficiary();
            beneficiary.setBeneficiaryId(rs.getLong("beneficiary_id"));
            beneficiary.setBeneficiaryCode(rs.getString("beneficiary_code"));
            beneficiary.setFullName(rs.getString("full_name"));
            beneficiary.setFamilySize(rs.getInt("family_size"));
            beneficiary.setPhone(rs.getString("phone"));
            beneficiary.setAddress(rs.getString("address"));
            beneficiary.setDistrict(rs.getString("district"));
            beneficiary.setCity(rs.getString("city"));
            beneficiary.setIsActive(rs.getString("is_active"));
            beneficiary.setCreatedAt(rs.getTimestamp("created_at") != null ? 
                rs.getTimestamp("created_at").toLocalDateTime() : null);
            beneficiary.setTotalDeliveries(rs.getInt("total_deliveries"));
            beneficiary.setTotalQuantityReceived(rs.getInt("total_quantity_received"));
            beneficiary.setTotalValueReceivedPen(rs.getDouble("total_value_received_pen"));
            beneficiary.setLastDeliveryDate(rs.getTimestamp("last_delivery_date") != null ? 
                rs.getTimestamp("last_delivery_date").toLocalDateTime() : null);
            return beneficiary;
        }
    }

    private static class ProgramRowMapper implements RowMapper<Program> {
        @Override
        public Program mapRow(ResultSet rs, int rowNum) throws SQLException {
            Program program = new Program();
            program.setProgramId(rs.getLong("program_id"));
            program.setProgramCode(rs.getString("program_code"));
            program.setProgramName(rs.getString("program_name"));
            program.setDescription(rs.getString("description"));
            program.setProgramType(rs.getString("program_type"));
            program.setStartDate(rs.getDate("start_date") != null ? 
                rs.getDate("start_date").toLocalDate() : null);
            program.setEndDate(rs.getDate("end_date") != null ? 
                rs.getDate("end_date").toLocalDate() : null);
            program.setIsActive(rs.getString("is_active"));
            program.setCreatedAt(rs.getTimestamp("created_at") != null ? 
                rs.getTimestamp("created_at").toLocalDateTime() : null);
            program.setTotalDonationsReceived(rs.getInt("total_donations_received"));
            program.setTotalDonationValuePen(rs.getDouble("total_donation_value_pen"));
            program.setTotalDeliveriesMade(rs.getInt("total_deliveries_made"));
            program.setTotalDeliveryValuePen(rs.getDouble("total_delivery_value_pen"));
            program.setUniqueBeneficiariesServed(rs.getInt("unique_beneficiaries_served"));
            program.setInventoryItems(rs.getInt("inventory_items"));
            return program;
        }
    }

    private static class DonationRowMapper implements RowMapper<Donation> {
        @Override
        public Donation mapRow(ResultSet rs, int rowNum) throws SQLException {
            Donation donation = new Donation();
            donation.setDonationId(rs.getLong("donation_id"));
            donation.setDonationCode(rs.getString("donation_code"));
            donation.setDonationDate(rs.getDate("donation_date") != null ? 
                rs.getDate("donation_date").toLocalDate() : null);
            donation.setDonorCode(rs.getString("donor_code"));
            donation.setDonorName(rs.getString("donor_name"));
            donation.setDonorType(rs.getString("donor_type"));
            donation.setDonationTypeName(rs.getString("donation_type_name"));
            donation.setAmount(rs.getDouble("original_amount"));
            donation.setCurrencyCode(rs.getString("currency_code"));
            donation.setCurrencySymbol(rs.getString("currency_symbol"));
            donation.setAmountInPen(rs.getDouble("amount_in_pen"));
            donation.setProductDescription(rs.getString("product_description"));
            donation.setQuantity(rs.getInt("quantity"));
            donation.setUnitValue(rs.getDouble("unit_value"));
            donation.setProgramCode(rs.getString("program_code"));
            donation.setProgramName(rs.getString("program_name"));
            donation.setNotes(rs.getString("notes"));
            donation.setCreatedByName(rs.getString("created_by_name"));
            donation.setCreatedAt(rs.getTimestamp("created_at") != null ? 
                rs.getTimestamp("created_at").toLocalDateTime() : null);
            return donation;
        }
    }

    private static class DeliveryRowMapper implements RowMapper<Delivery> {
        @Override
        public Delivery mapRow(ResultSet rs, int rowNum) throws SQLException {
            Delivery delivery = new Delivery();
            delivery.setDeliveryId(rs.getLong("delivery_id"));
            delivery.setDeliveryCode(rs.getString("delivery_code"));
            delivery.setDeliveryDate(rs.getDate("delivery_date") != null ? 
                rs.getDate("delivery_date").toLocalDate() : null);
            delivery.setStatus(rs.getString("status"));
            delivery.setBeneficiaryCode(rs.getString("beneficiary_code"));
            delivery.setBeneficiaryName(rs.getString("beneficiary_name"));
            delivery.setFamilySize(rs.getInt("family_size"));
            delivery.setDistrict(rs.getString("district"));
            delivery.setCity(rs.getString("city"));
            delivery.setProgramCode(rs.getString("program_code"));
            delivery.setProgramName(rs.getString("program_name"));
            delivery.setProgramType(rs.getString("program_type"));
            delivery.setProductDescription(rs.getString("product_description"));
            delivery.setQuantityDelivered(rs.getInt("quantity_delivered"));
            delivery.setUnitValue(rs.getDouble("unit_value"));
            delivery.setTotalValue(rs.getDouble("total_value"));
            delivery.setNotes(rs.getString("notes"));
            delivery.setCreatedByName(rs.getString("created_by_name"));
            delivery.setApprovedByName(rs.getString("approved_by_name"));
            delivery.setCreatedAt(rs.getTimestamp("created_at") != null ? 
                rs.getTimestamp("created_at").toLocalDateTime() : null);
            return delivery;
        }
    }

    // ================================================================
    // USER OPERATIONS
    // ================================================================

    /**
     * Get user by username
     */
    public User getUserByUsername(String username) {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.email, u.role_id, " +
                    "r.role_name, u.is_active, u.last_login, u.created_at, u.updated_at " +
                    "FROM tbl_users u " +
                    "JOIN tbl_roles r ON u.role_id = r.role_id " +
                    "WHERE UPPER(u.username) = UPPER(?)";
        
        try {
            List<User> users = jdbcTemplate.query(sql, new UserRowMapper(), username);
            return users.isEmpty() ? null : users.get(0);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Get user by ID
     */
    public User getUserById(Long userId) {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.email, u.role_id, " +
                    "r.role_name, u.is_active, u.last_login, u.created_at, u.updated_at " +
                    "FROM tbl_users u " +
                    "JOIN tbl_roles r ON u.role_id = r.role_id " +
                    "WHERE u.user_id = ?";
        
        try {
            List<User> users = jdbcTemplate.query(sql, new UserRowMapper(), userId);
            return users.isEmpty() ? null : users.get(0);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Update user last login
     */
    public void updateUserLastLogin(Long userId) {
        String sql = "UPDATE tbl_users SET last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
        try {
            jdbcTemplate.update(sql, userId);
        } catch (Exception e) {
            // Ignore if update fails
        }
    }

    /**
     * ROW MAPPER FOR USERS
     */
    private static class UserRowMapper implements RowMapper<User> {
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            User user = new User();
            user.setUserId(rs.getLong("user_id"));
            user.setUsername(rs.getString("username"));
            user.setFullName(rs.getString("full_name"));
            user.setEmail(rs.getString("email"));
            user.setRoleId(rs.getLong("role_id"));
            user.setRoleName(rs.getString("role_name"));
            user.setIsActive(rs.getString("is_active"));
            user.setLastLogin(rs.getTimestamp("last_login") != null ? 
                rs.getTimestamp("last_login").toLocalDateTime() : null);
            user.setCreatedAt(rs.getTimestamp("created_at") != null ? 
                rs.getTimestamp("created_at").toLocalDateTime() : null);
            user.setUpdatedAt(rs.getTimestamp("updated_at") != null ? 
                rs.getTimestamp("updated_at").toLocalDateTime() : null);
            return user;
        }
    }
}