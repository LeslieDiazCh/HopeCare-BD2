package com.hopecare.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.sql.DataSource;

/**
 * Database & Web Configuration
 * Configures JDBC Template and Security Interceptor
 */
@Configuration
public class DatabaseConfig implements WebMvcConfigurer {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private SecurityInterceptor securityInterceptor;

    /**
     * JDBC Template Bean
     */
    @Bean
    public JdbcTemplate jdbcTemplate() {
        return new JdbcTemplate(dataSource);
    }

    /**
     * Register Security Interceptor
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(securityInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns("/login", "/api/login", "/css/**", "/js/**", "/api/session");
    }
}