package ru.etu.hotel.model.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "specification")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BomSpecification {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "product_id", nullable = false)
    private Integer productId;

    @Column(name = "designation", length = 50, nullable = false, unique = true)
    private String designation;

    @Column(name = "spec_type", length = 20, nullable = false)
    private String specType;

    @Column(name = "base_spec_id")
    private Integer baseSpecId;

    @Column(name = "status", length = 20, nullable = false)
    private String status;

    @Column(name = "description")
    private String description;
}