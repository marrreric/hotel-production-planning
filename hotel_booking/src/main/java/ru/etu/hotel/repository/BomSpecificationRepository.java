package ru.etu.hotel.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import ru.etu.hotel.model.entity.BomSpecification;

import java.util.List;

@Repository
public interface BomSpecificationRepository extends JpaRepository<BomSpecification, Integer> {

    @Query(value = "SELECT * FROM specification WHERE product_id = :productId AND spec_type = 'Базовая' AND status = 'Действует' LIMIT 1", nativeQuery = true)
    BomSpecification findActiveBaseByProduct(@Param("productId") Integer productId);

    @Query(value = "SELECT * FROM specification WHERE designation = :designation", nativeQuery = true)
    BomSpecification findByDesignation(@Param("designation") String designation);

    @Query(value = "SELECT * FROM specification ORDER BY id", nativeQuery = true)
    List<BomSpecification> findAllOrdered();
}